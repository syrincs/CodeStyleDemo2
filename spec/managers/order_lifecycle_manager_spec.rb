require 'rails_helper'
require 'ostruct'

RSpec.describe OrderLifecycleManager do
  let!(:buyer) { create :user, address: 'uniq address' }
  let!(:order_status) { 'created' }
  let!(:product) { create :product, title: 'New iPhone 5S' }
  let!(:order) { create :order, user: buyer, price_cents: 5000, status: order_status, product: product }
  let!(:performer) { order.seller }
  let!(:seller_bank_acount) { create(:bank_account, user: order.seller) }
  let(:manager) { described_class.new(order, performer) }
  let!(:credit_card) { create :credit_card }
  let!(:request) { OpenStruct.new(remote_ip: "127.0.0.1") }
  let(:cvv) { 123 }


  before do
    allow_any_instance_of(StripeBillingManager).to receive(:authorize_and_charge)
  end

  describe '#order_purchase' do
    subject { manager.order_purchase(credit_card, cvv, request) }

    it 'sets buyers address as order address' do
      expect(order.address).to be_nil
      subject
      expect(order.reload.address).not_to eql(buyer.address)
      expect(order.reload.address.address1).to eql('uniq address')
    end

    it 'creates charge for order' do
      expect { subject }.to have_created_charge(:success).for_order(order).for_user(order.buyer).with_amount_cents(order.price_cents)
    end

    it 'creates transaction' do
      expect { subject }.to have_created_transaction(:success).for(order.charges.first).with_amount_cents(5000).with_payable(credit_card)
    end

    it 'sends email to the seller' do
      expect { subject }.to deliver_mail(ProductMailer, :purchased_seller).with(order.product.id)
    end

    it 'sends email to the buyer' do
      expect { subject }.to deliver_mail(ProductMailer, :purchased_buyer).with(order.product.id)
    end

    it 'reminds the seller to add a bankaccount if he has none' do
      product.seller.bank_accounts.delete_all
      expect { subject }.to deliver_mail(UserMailer, :please_add_bank_account)
    end

    it 'authorizes and charges amount' do
      allow(order.seller).to receive(:stripe_managed_account_id).and_return("act_fake_stripe_account")

      expect_any_instance_of(StripeBillingManager).to receive(:authorize_and_charge).with(
        credit_card: credit_card,
        amount_in_cents: 5000,
        verification_code: 123,
        fee_in_cents: (5000 * 0.05),
        destination_account_id: "act_fake_stripe_account"
      ).and_return('111111')
      subject
    end

    it 'changes order\'s status to paid' do
      expect { subject }.to change(order, :status).to('paid')
    end

    it 'creates empty shipment' do
      expect { subject }.to change { order.reload.shipment }.from(nil).to(instance_of(Shipment))
    end

    it 'creates activity' do
      expect { subject }.to have_created_activity('Buyer paid for the order').for(order)
    end

    context 'when order status is not unpaid' do
      let!(:order) { create :order, status: 'paid' }
      specify { expect { subject }.to raise_error OrderLifecycleManager::ValidationError, 'Order already purchased' }
    end

    context 'when credit card is blank' do
      let!(:credit_card) { nil }
      specify { expect { subject }.to raise_error OrderLifecycleManager::ValidationError, 'Please select a payment method' }
    end
  end

  describe '#order_shipped' do
    subject { manager.order_shipped('EZ4000000004') }

    it 'sets #shipment.tracking_number to order' do
      expect { subject }.to change { order.shipment.try(:tracking_number) }.from(nil).to('EZ4000000004')
    end

    it 'sets #shipped_at to order', freeze: true do
      expect { subject }.to change(order, :shipped_at).from(nil).to(Time.zone.now)
    end

    it 'sets #status to shipped for order' do
      expect { subject }.to change(order, :status).to('shipped')
    end

    specify do
      expect { subject }.to have_created_activity('Order marked as shipped. Tracking number EZ4000000004').for(order)
    end

    it 'runs creates an EasypostTrackerCreationWorker job' do
      allow(EasypostTrackerCreationWorker).to receive(:perform_async)
      subject
      expect(EasypostTrackerCreationWorker).to have_received(:perform_async)
    end

    context 'when wrong performer' do
      let!(:performer) { create :user }
      specify { expect { subject }.to raise_error OrderLifecycleManager::ValidationError, 'You can\'t edit this order' }
    end

    context 'when ActiveRecord::ActiveRecordError raised' do
      before do
        allow(order).to receive(:save!).and_raise(ActiveRecord::RecordInvalid, Order.new)
      end
      specify { expect { subject }.to raise_error OrderLifecycleManager::ValidationError }
    end
  end

  describe '#order_not_shipped' do
    before do
      manager.order_shipped('EZ4000000004')
    end

    subject { manager.order_not_shipped('error') }

    it 'clears order.shipment.tracking_number' do
      expect { subject }.to change { order.shipment.tracking_number }.from('EZ4000000004').to(nil)
    end

    it 'clears order.shipped_at', freeze: true do
      expect { subject }.to change(order, :shipped_at).from(Time.zone.now).to(nil)
    end

    it 'clears order.status' do
      expect { subject }.to change(order, :status).from('shipped').to('paid')
    end

    it 'creates activity' do
      message = 'Some error occurred. Please contact us if you have some problems. Error: error'
      expect { subject }.to have_created_activity(message).for(order)
    end

    context 'when ActiveRecord::ActiveRecordError raised' do
      before do
        allow(order).to receive(:save!).and_raise(ActiveRecord::RecordInvalid, Order.new)
      end
      specify { expect { subject }.to raise_error OrderLifecycleManager::ValidationError }
    end
  end

  describe '#order_received' do
    subject { manager.order_received }
    let!(:order_status) { 'shipped' }

    it 'updates status to :delivered' do
      expect { subject }.to change(order, :status).to('delivered')
    end

    specify do
      expect { subject }.to have_created_activity('Product delivered').for(order)
    end

    context 'when order is not shipped' do
      let!(:order_status) { 'paid' }
      specify do
        expect { subject }.to raise_error OrderLifecycleManager::ValidationError, 'Order is not shipped yet'
      end
    end
  end

  describe '#buy_shipping_label' do
    let!(:order_status) { 'not_paid' }
    let!(:parcel_attributes) { ActionController::Parameters.new(width: 10, height: 10, length: 10, weight: 10) }
    let!(:easypost_shipment) { create :easypost_shipment }
    let!(:request) { OpenStruct.new(remote_ip: "127.0.0.1") }

    before do
      allow(EasyPost::Shipment).to receive(:create).and_return(easypost_shipment)
      allow(easypost_shipment).to receive(:buy).and_return(easypost_shipment)
    end
    before { manager.order_purchase(credit_card, cvv, request) }
    subject { manager.buy_shipping_label(parcel_attributes) }

    it 'updates shipment.width' do
      expect { subject }.to change { order.reload.shipment.width }.from(nil).to(10)
    end

    it 'updates shipment.height' do
      expect { subject }.to change { order.reload.shipment.height }.from(nil).to(10)
    end

    it 'updates shipment.length' do
      expect { subject }.to change { order.reload.shipment.length }.from(nil).to(10)
    end

    it 'updates shipment.weight' do
      expect { subject }.to change { order.reload.shipment.weight }.from(nil).to(10)
    end

    it 'updates shipment.shipment_id' do
      expect { subject }.to change { order.reload.shipment.shipment_id }.from(nil).to(easypost_shipment.id)
    end

    it 'updates shipment.postage_label_url' do
      expect { subject }.to change { order.reload.shipment.postage_label_url }.from(nil).to('http://assets.geteasypost.com/postage_labels/labels/lUoagDx.png')
    end

    it 'updates shipment.tracker_status' do
      expect { subject }.to change { order.reload.shipment.tracker_status }.from(nil).to('in_transit')
    end

    it 'updates shipment.tracker_id' do
      expect { subject }.to change { order.reload.shipment.tracker_id }.from(nil).to(easypost_shipment.tracker.id)
    end

    specify do
      allow(manager).to receive(:order_shipped).with(easypost_shipment.tracker.tracking_code)
      subject
      expect(manager).to have_received(:order_shipped).with(easypost_shipment.tracker.tracking_code)
    end

    specify do
      expect(subject).to eql 'http://assets.geteasypost.com/postage_labels/labels/lUoagDx.png'
    end
  end

  describe '#create_returning_issue' do
    let!(:order_status) { 'not_paid' }
    let!(:parcel_attributes) { ActionController::Parameters.new(width: 10, height: 10, length: 10, weight: 10) }
    let!(:easypost_tracker) { create :easypost_tracker, tracking_code: 'TRACKING_CODE_001' }
    let!(:easypost_shipment) { create :easypost_shipment, tracker: easypost_tracker }
    let!(:issue) { create :issue }
    let!(:request) { OpenStruct.new(remote_ip: "127.0.0.1") }

    before do
      allow(EasyPost::Shipment).to receive(:create).and_return(easypost_shipment)
      allow(easypost_shipment).to receive(:buy).and_return(easypost_shipment)
      manager.order_purchase(credit_card, cvv, request)
      manager.buy_shipping_label(parcel_attributes)
    end

    subject { manager.create_returning_issue issue }

    specify { expect(subject).to be_a(Issue) }

    it 'assigns order to the issue' do
      expect(subject.order).to be order
    end

    specify do
      expect { subject }.to have_created_activity('Buyer has initiated return process').for(order)
    end

    specify do
      expect { subject }.to have_created_activity('Issue was created').for(issue)
    end

    specify do
      message = 'Return shipping label was created. Tracking number TRACKING_CODE_001'
      expect { subject }.to have_created_activity(message).for(issue)
    end

    it 'sends email to the seller' do
      expect { subject }.to deliver_mail(ReturnMailer, :issue_created).with(issue.id)
      mail = ReturnMailer.deliveries.last
      expect(mail.subject).to eql 'Buyer has started a return of "New iPhone 5S"'
    end

    context 'when order has a shipment' do
      before { subject }

      it 'creates return shipment' do
        expect(issue.shipment).to be_a Shipment
        expect(issue.shipment).to be_present
        expect(issue.shipment.parcel_attributes).to eql order.shipment.parcel_attributes
      end

      it 'assigns shipment_id to shipment' do
        expect(issue.shipment.shipment_id).to eql easypost_shipment.id
      end

      it 'assigns postage_label_url to shipment' do
        expect(issue.shipment.postage_label_url).to eql easypost_shipment.postage_label.label_url
      end
    end
  end
end
