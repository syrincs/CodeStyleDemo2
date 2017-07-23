require 'rails_helper'
require 'ostruct'

RSpec.describe Dashboard::StoreOrdersController, type: :controller do
  let(:buyer) { create(:buyer) }
  let(:seller) { create(:seller) }
  let(:cvv) { 123 }
  let!(:order) { create(:order, buyer: buyer, seller: seller) }

  describe 'POST buy_shipping_label' do
    let(:current_user) { seller }
    let!(:credit_card) { create :credit_card }


    before { allow_any_instance_of(StripeBillingManager).to receive(:authorize_and_charge).and_return('123') }
    before { OrderLifecycleManager.new(order, current_user).order_purchase(credit_card, cvv, OpenStruct.new(remote_ip: "127.0.0.1")) }
    before { login_user current_user }

    subject { post :buy_shipping_label, request_body.merge(id: order.id) }

    context 'with valid params' do
      let(:request_body) { {shipment: {width: 100, height: 100, length: 100, weight: 10}} }
      let!(:shipment) { create(:easypost_shipment, id: 'shp_ggDdJa6E') }

      before do
        allow(EasyPost).to receive(:request).and_return({})
        allow(EasyPost::Shipment).to receive(:create).and_return(shipment)
      end

      it 'stores shipment_id' do
        expect { subject }.to change { order.reload.shipment.try(:shipment_id) }.from(nil).to('shp_ggDdJa6E')
      end

      it 'stores tracker id and status' do
        subject
        order.reload
        expect(order.shipment.tracker_id).to eql shipment.tracker.id
        expect(order.shipment.tracker_status).to eql shipment.tracker.status
      end

      it 'stores postage label' do
        expect { subject }.to change { order.reload.shipment.try(:postage_label_url) }.to eql shipment.postage_label.label_url
      end

      specify do
        expect(subject).to redirect_to action: :show, id: order.id
      end

      it 'assign flash notice message' do
        subject
        expect(flash[:notice]).to eql 'Order has been marked as shipped'
      end
    end

    context 'with invalid params' do
      let(:request_body) { {shipment: {}} }
      specify { expect(subject).to render_template 'show' }
    end
  end
end
