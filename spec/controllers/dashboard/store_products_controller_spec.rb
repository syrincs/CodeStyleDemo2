require 'rails_helper'

RSpec.describe Dashboard::StoreProductsController, type: :controller do
  let(:buyer) { create(:buyer) }
  let(:seller) { create(:seller) }
  let(:current_user) { buyer }
  let!(:category) { create :category }

  describe 'POST create' do
    let(:current_user) { seller }
    subject { post :create, request_body }
    before { login_user current_user }

    context 'with valid params' do
      let(:request_body) { {product: attributes_for(:product, ships_from_address_id: seller.address.id, categorization_attributes: {category_id: category.id})} }

      it 'creates a product' do
        expect { subject }.to change(Product, :count).by(1)
      end

      it 'assigns product' do
        subject
        expect(assigns(:product)).to be_a Product
      end

      it 'attaches product to current user' do
        subject
        expect(assigns(:product).seller.id).to be current_user.id
      end

      it 'sends email to the seller' do
        expect { subject }.to deliver_mail(ProductMailer, :new_product_for_moderation)
      end

      it 'creates an order' do
        expect { subject }.to change(Order, :count).by(1)
      end
    end

    context 'with invalid params' do
      let(:request_body) { {product: attributes_for(:product, title: nil, categorization_attributes: {category_id: category.id})} }

      it 'does not create a product' do
        expect { subject }.not_to change(Product, :count)
      end

      it 'assigns a product to be able show errors' do
        subject
        expect(assigns(:product)).to be_a Product
      end

      it 'does not send email to the seller' do
        expect { subject }.not_to deliver_mail(ProductMailer, :created)
      end

      it 'does not create an order' do
        expect { subject }.not_to change(Order, :count)
      end
    end

    context 'google analytics data layer' do
      let(:attributes) { attributes_for(:product, ships_from_address_id: seller.address.id, categorization_attributes: {category_id: category.id}) }
      let(:request_body) { {product: attributes} }

      it 'push create event to data layer' do
        subject
        expect(session[:data_layer]).to eql [{event: 'VirtualPageview',
                                              virtualPageURL: "/add_product/funnel/#{Product.last.slug}",
                                              virtualPageTitle: 'virturl: Add new Product – Final step'}]
      end
    end
  end
end
