require 'rails_helper'
require 'ostruct'

RSpec.describe AuctionLifecycleManager do
  let!(:performer) { create :buyer }
  let!(:product) { create :product, price_cents: 100000 }
  let(:manager) { described_class.new(product, performer) }
  let(:cvv) { 123 }
  let!(:request) { OpenStruct.new(remote_ip: "127.0.0.1") }

  before do
    allow_any_instance_of(StripeBillingManager).to receive(:authorize_and_charge)
  end

  describe '#bid' do
    let!(:credit_card) { create :credit_card, user: performer }
    let(:offer_amount) { 200 }
    let!(:request) { OpenStruct.new(remote_ip: "127.0.0.1") }
    subject { manager.bid(offer_amount, credit_card, cvv, request) }

    it 'creates offer' do
      expect { subject }.to change(product.offers, :count).from(0).to(1)
      expect(product.offers.first.amount.to_i).to eql offer_amount
      expect(product.offers.first.user).to eql performer
    end

    it 'reminds the seller to add a bankaccount if he has none' do
      product.seller.bank_accounts.delete_all
      expect { subject }.to deliver_mail(UserMailer, :please_add_bank_account)
    end

    specify do
      expect { subject }.to have_created_charge(:success).for_order(product.order).for_user(performer).with_amount_cents(200)
    end

    specify do
      expect { subject }.to have_created_transaction(:success).with_amount_cents(200).with_payable(credit_card)
    end

    it 'authorizes the 1bid1 offer fee ($2) in billing service for further charge'  do
      allow(product.seller).to receive(:stripe_managed_account_id).and_return("act_stripe_yadada")
      expect_any_instance_of(StripeBillingManager).to receive(:authorize_and_charge).with(
        credit_card: credit_card,
        amount_in_cents: 200,
        fee_in_cents: 100,
        destination_account_id: "act_stripe_yadada",
        verification_code: cvv
      ).and_return('111111')
      subject
    end

    def new_bid
      amount = product.highest_offer.try(:amount) || 200
      described_class.new(product, create(:buyer)).bid(amount.to_f + 200, credit_card, cvv, request)
    end

    it 'decreases product\'s price by $1' do
      allow_any_instance_of(StripeBillingManager).to receive(:authorize_and_charge).and_return('111111')
      expect { new_bid }.to change(product, :price_cents).from(100000).to(99900)
      expect { new_bid }.to change(product, :price_cents).from(99900).to(99800)
      expect { new_bid }.to change(product, :price_cents).from(99800).to(99700)
    end

    it 'do not change original price' do
      allow_any_instance_of(StripeBillingManager).to receive(:authorize_and_charge).and_return('111111')
      expect { new_bid }.not_to change(product, :original_price)
      expect { new_bid }.not_to change(product, :original_price)
      expect { new_bid }.not_to change(product, :original_price)
      expect(product.price_cents).to eql 99700
    end

    it 'caches highest offer amount' do
      expect { new_bid }.to change(product, :highest_offer_amount_cents).from(nil).to(40000)
    end

    it 'sends email to the seller' do
      expect { subject }.to deliver_mail(OfferMailer, :offer_created)
    end

    context 'when previous offer exsists' do
      let(:offer_amount) { 500 }
      before do
        allow_any_instance_of(StripeBillingManager).to receive(:authorize_and_charge).and_return('111111')
      end

      it 'sends email to the outbid offer' do
        new_bid
        expect { subject }.to deliver_mail(OfferMailer, :offer_outbid)
      end
    end

    context 'when seller tries to make a bid' do
      let(:performer) { product.seller }
      specify { expect { subject }.to raise_error described_class::ValidationError, "You can't make an offer on your own product." }
    end

    context 'when product is sold' do
      let!(:product) { create :product, sold: true }
      specify { expect { subject }.to raise_error described_class::ValidationError, "Product already sold." }
    end

    context 'when amount of the bid is less than highest offer' do
      let(:offer_amount) { 100 }
      let!(:highest_offer) { create :offer, amount: 200, product: product }
      specify { expect { subject }.to raise_error described_class::ValidationError, "Your offer must be higher than current highest." }
    end

    context 'when amount of the bid is equal to highest offer' do
      let!(:highest_offer) { create :offer, amount: 200, product: product }
      let(:offer_amount) { 200 }
      specify { expect { subject }.to raise_error described_class::ValidationError, "Your offer must be higher than current highest." }
    end

    context 'when amount is less than 0' do
      let(:offer_amount) { -1 }
      specify { expect { subject }.to raise_error described_class::ValidationError, "Your offer must be positive." }
    end

    context 'when amount is equal to 0' do
      let(:offer_amount) { 0 }
      specify { expect { subject }.to raise_error described_class::ValidationError, "Your offer must be positive." }
    end

    context 'when amount is higher than product price - $2' do
      let!(:product) { create :product, price: 1000 }
      let(:offer_amount) { 2000 }
      specify { expect { subject }.to raise_error described_class::ValidationError, "Your offer couldn't be higher than current buy price." }
    end

    context 'when amount equals to product price - $2' do
      let!(:product) { create :product, price: 1000 }
      let(:offer_amount) { 1000 }
      specify { expect { subject }.to raise_error described_class::ValidationError, "Your offer couldn't be higher than current buy price." }
    end

    context 'when amount less than product price - $2 by $1' do
      let!(:product) { create :product, price: 1000 }
      let(:offer_amount) { 997 }
      specify { expect { subject }.not_to raise_error }
    end

    context 'when wrong credit card' do
      let(:credit_card) { nil }
      specify { expect { subject }.to raise_error described_class::ValidationError, "Please provide correct credit card." }
    end

    context 'when StripeBillingManager::ValidationError raised' do
      before do
        allow_any_instance_of(StripeBillingManager).to receive(:authorize_and_charge).and_raise(StripeBillingManager::ValidationError, '-message-')
      end
      specify { expect { subject }.to raise_error described_class::ValidationError, "Offer is not placed. We can't charge your card Visa XXXX-XXXX-XXXX-4242. System Error: -message-." }
    end
  end

  describe '#accept_offer' do
    let!(:product) { create :product, :with_empty_order, user: performer }
    let!(:offer) { create :offer, product: product, amount: 999 }
    subject { manager.accept_offer(offer) }

    it 'sends email to the buyer' do
      expect { subject }.to deliver_mail(OfferMailer, :offer_accepted).with(offer.id)
    end

    it 'creates activity' do
      expect { subject }.to have_created_activity('Bid $999.00 accepted').for(product)
    end

    it 'makes the product sold' do
      expect { subject }.to change(product, :sold).from(false).to(true)
    end

    it 'makes the offer accepted' do
      expect { subject }.to change(offer, :accepted).from(nil).to(true)
    end

    it 'changes the order\'s status not_paid' do
      expect { subject }.to change(product.order, :status).from('created').to('not_paid')
    end

    it 'changes the order\'s buyer to the performer' do
      expect { subject }.to change(product.order, :buyer).to(offer.user)
    end

    it 'changes the order\'s price' do
      expect { subject }.to change(product.order, :price_cents).to(99900)
    end

    context 'when performer is not the owner' do
      let!(:offer) { create :offer, :with_product, amount: 999 }
      specify { expect { subject }.to raise_error described_class::ValidationError, 'You are not the owner of the product' }
    end
  end

  describe '#buy' do
    let!(:seller) { create :seller }
    let!(:credit_card) { create :credit_card, user: performer }
    let!(:product) { create :product, :with_empty_order, user: seller, price: 999 }
    let(:cvv) { 123 }
    let!(:request) { OpenStruct.new(remote_ip: "127.0.0.1") }

    subject { manager.buy(credit_card, cvv, request) }

    it 'calls OrderLifecycleManager#order_purchase' do
      order_lifecycle_manager = double(order_purchase: true)
      expect(OrderLifecycleManager).to receive(:new).with(product.order, performer).and_return(order_lifecycle_manager)
      expect(order_lifecycle_manager).to receive(:order_purchase)
      subject
    end

    it 'creates activity for order' do
      expect { subject }.to have_created_activity('Product purchased').for(product.order)
    end

    it 'creates activity for product' do
      expect { subject }.to have_created_activity('Product sold').for(product)
    end

    it 'makes the product sold' do
      expect { subject }.to change(product, :sold).from(false).to(true)
    end

    it 'changes the order\'s status not_paid' do
      expect { subject }.to change(product.order, :status).from('created').to('paid')
    end

    it 'changes the order\'s buyer to the performer' do
      expect { subject }.to change(product.order, :buyer).to(performer)
    end

    it 'changes the order\'s price' do
      expect { subject }.to change(product.order, :price_cents).to(99900)
    end

    context 'when product has already been sold' do
      before { product.update! sold: true }
      specify { expect { subject }.to raise_error described_class::ValidationError, 'Product has already been sold.' }
    end

    context 'when performer is the seller' do
      let!(:seller) { performer }
      specify { expect { subject }.to raise_error described_class::ValidationError, 'You can\'t purchase your own product' }
    end
  end
end
