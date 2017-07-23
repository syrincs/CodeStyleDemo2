require 'rails_helper'

RSpec.describe Dashboard::OrdersController, type: :controller do
  let(:buyer) { create(:buyer) }
  let!(:order) { create :order, user: buyer, price_cents: 999, status: order_status }
  let(:cvv) { '123' }
  let(:current_user) { buyer }

  before do
    login_user(current_user)
  end

  describe 'POST order_purchase' do
    let!(:order_status) { 'created' }
    let!(:credit_card) { create :credit_card, user: buyer }
    let(:request_body) { { id: order.id, credit_card: { id: credit_card.id, verification_value: cvv } } }
    let!(:billing) { stub_billing(current_user) }

    subject { post :purchase, request_body }

    it 'charges buyer via billing' do
      order.seller.update_attributes(stripe_managed_account_id: "acct_19F5QGHeRmdEtG34")

      subject
      expect(billing)
        .to have_received(:authorize_and_charge)
        .with(
          credit_card: credit_card,
          amount_in_cents: 999,
          verification_code: "123",
          fee_in_cents: (999 * 0.05).to_i,
          destination_account_id: order.seller.stripe_managed_account_id
        )
    end

    specify { expect(subject).to redirect_to(dashboard_order_path(order)) }

    specify do
      subject
      expect(flash[:notice]).to eql "You have just purchased order ##{order.public_id}"
    end

    it 'sets order\'s status to :paid' do
      expect { subject }.to change { order.reload.status.to_sym }.to(:paid)
    end

    context 'when OrderLifecycleManager::ValidationError is raised' do
      before do
        manager = OrderLifecycleManager.new(order, current_user)
        allow(OrderLifecycleManager).to receive(:new).and_return(manager)
        allow(manager).to receive(:order_purchase).and_raise(OrderLifecycleManager::ValidationError, 'message')
      end

      specify { expect(subject).to redirect_to(:back) }

      it 'puts error message to flash[:alert]' do
        subject
        expect(flash[:alert]).to eql 'message'
      end
    end
  end

  describe 'POST order_received' do
    let!(:seller_bank_acount) { create(:bank_account, user: order.seller) }
    let!(:order_status) { 'shipped' }
    let(:request_body) { { id: order.id, format: :json } }

    subject { post :received, request_body }

    specify do
      subject
      expect(flash[:notice]).to eql 'Order has been marked as received'
    end

    it 'sets order\'s status to :delivered' do
      expect { subject }.to change { order.reload.status.to_sym }.to(:delivered)
    end
  end
end
