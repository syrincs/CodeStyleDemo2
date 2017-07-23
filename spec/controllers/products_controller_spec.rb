require 'rails_helper'

RSpec.describe ProductsController, type: :controller, stripe: true do
  let(:buyer) { create(:buyer) }
  let(:seller) { create(:seller) }
  let(:current_user) { buyer }
  let!(:category) { create :category }

  describe 'GET show' do
    let!(:product) { create :product, :with_empty_order, user: seller, title: 'New iPhone 5S', price: 599.99 }
    subject { get :show, id: product.slug, category: product.category.code }
    before { ProductsIndex::Product.import product }

    context 'google analytics data layer' do
      it 'pushes event to data layer' do
        subject
        expect(assigns(:_data_layer)).to eql [{pageCategory: product.category.name}]
      end
      context 'when just created' do
        before do
          session[:data_layer] = [{event: 'VirtualPageview',
                                   virtualPageURL: "/add_product/funnel/#{product.slug}",
                                   virtualPageTitle: 'virturl: Add new Product – Final step'}]
        end

        it 'has event virtual pageview' do
          subject
          expect(assigns(:_data_layer)).to include event: 'VirtualPageview',
                                                   virtualPageURL: "/add_product/funnel/#{product.slug}",
                                                   virtualPageTitle: 'virturl: Add new Product – Final step'
        end
      end
    end
  end

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
      let(:request_body) { {product: attributes_for(:product, title: nil)} }

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
  end

  describe 'POST buy' do
    let!(:product) { create :product, :with_empty_order, user: seller, title: 'New iPhone 5S', price: 599.99 }
    let(:request_body) { {id: product.slug, order: {product_id: product.id}} }
    let(:credit_card_params) { attributes_for(:raw_stripe_credit_card) }

    subject { post :buy, request_body }

    context 'when product is sold' do
      let!(:billing) { stub_billing(instance_of(User)) }
      before do
        allow_billing_to_create_profile
        allow_billing_to_create_credit_card
      end

      let(:request_body) { {id: product.slug, email: 'guest@example.com', credit_card: credit_card_params, order: {product_id: product.id}} }
      let!(:product) { create :product, user: seller, sold: true }
      before { subject }

      specify { expect(response).to redirect_to(:back) }
      context 'alert message' do
        specify { expect(flash[:alert]).to eql 'Product has already been sold.' }
      end
    end

    context 'when user is signed in' do
      before { login_user buyer }
      let!(:billing) { stub_billing(buyer) }

      context 'and current user is seller' do
        before { login_user seller }
        before { subject }
        let(:request_body) { {id: product.slug, credit_card: {id: 1, verification_value: 123}, order: {product_id: product.id}} }

        specify { expect(response).to redirect_to(:back) }
        context 'alert message' do
          specify { expect(flash[:alert]).to eql "You can't purchase your own product" }
        end
      end

      context 'and params is fine' do
        before { subject }
        let!(:credit_card) { create :credit_card, user: buyer }
        let(:request_body) { {id: product.slug, credit_card: {id: credit_card.id, verification_value: 123}, order: {product_id: product.id}} }

        specify { expect(response).to redirect_to(dashboard_order_path(product.order)) }
        context 'alert message' do
          specify { expect(flash[:notice]).to eql 'You have just bought New iPhone 5S' }
        end

        context 'google analytics data layer' do
          it 'pushes ThankYou event to data layer' do
            expect(session[:data_layer]).to eql [{pageType: 'ThankYou',
                                                  transactionId: product.order.public_id,
                                                  transactionAffiliation: product.seller.id,
                                                  transactionTotal: 599.99,
                                                  transactionShipping: 0,
                                                  transactionProducts: [{sku: product.sku,
                                                                         name: product.title,
                                                                         category: product.category.name,
                                                                         price: 599.99,
                                                                         quantity: 1}]}]
          end
        end
      end
    end

    context 'when user is not signed in' do
      before { logout_user }
      let!(:billing) { stub_billing(instance_of(User)) }
      before do
        allow_billing_to_create_profile
        allow_billing_to_create_credit_card
      end

      context 'and there is a user with given email' do
        before { create :user, email: 'guest@example.com' }
        before { subject }
        let(:request_body) { {id: product.slug, email: 'guest@example.com', order: {product_id: product.id}} }

        specify { expect(response).to redirect_to(:back) }
        context 'alert message' do
          specify { expect(flash[:alert]).to eql 'Email is already taken' }
        end
      end

      context 'and there is no credit card' do
        before { subject }
        let(:request_body) { {id: product.slug, email: 'guest@example.com', order: {product_id: product.id}} }

        specify { expect(response).to redirect_to(:back) }
        context 'alert message' do
          specify { expect(flash[:alert]).to eql 'Please select a payment method' }
        end
      end

      xcontext 'and params is fine' do
        let(:request_body) { {id: product.slug, credit_card: credit_card_params, email: 'guest@example.com', order: {product_id: product.id}} }

        before { subject }

        specify { expect(response).to redirect_to(dashboard_order_path(product.order)) }
        context 'alert message' do
          specify { expect(flash[:notice]).to eql 'You just bought New iPhone 5S' }
        end
      end
    end
  end

  describe 'POST bid' do
    let(:amount) { 100 }
    let(:request_body) { {id: product.slug, offer: {product_id: product.id, amount: amount}, credit_card: {id: credit_card.id, verification_value: 123}} }

    before { login_user current_user }
    subject { post :bid, request_body }

    let!(:product) { create :product, user: seller, price: 599.99 }
    let!(:credit_card) { create :credit_card, user: buyer }

    context 'when seller tries to make a bid' do
      let(:current_user) { seller }
      before { subject }

      specify { expect(response).to redirect_to(:back) }
      context 'alert message' do
        specify { expect(flash[:alert]).to eql "You can't make an offer on your own product." }
      end
    end

    context 'when product is sold' do
      let!(:product) { create :product, user: seller, sold: true }
      before { subject }

      specify { expect(response).to redirect_to(:back) }
      context 'alert message' do
        specify { expect(flash[:alert]).to eql 'Product already sold.' }
      end
    end

    context 'when amount of the bid is less than highest offer' do
      let!(:highest_offer) { create :offer, amount: 200, product: product }
      let(:amount) { 100 }
      before { subject }

      specify { expect(response).to redirect_to(:back) }
      context 'alert message' do
        specify { expect(flash[:alert]).to eql "Your offer must be higher than current highest." }
      end
    end

    context 'when amount of the bid is equal to highest offer' do
      let!(:highest_offer) { create :offer, amount: 200, product: product }
      let(:amount) { 200 }
      before { subject }

      specify { expect(response).to redirect_to(:back) }
      context 'alert message' do
        specify { expect(flash[:alert]).to eql "Your offer must be higher than current highest." }
      end
    end

    context 'when amount is less than 0' do
      let(:amount) { -1 }
      before { subject }

      specify { expect(response).to redirect_to(:back) }
      context 'alert message' do
        specify { expect(flash[:alert]).to eql "Your offer must be positive." }
      end
    end

    context 'when amount is equal to 0' do
      let(:amount) { 0 }
      before { subject }

      specify { expect(response).to redirect_to(:back) }
      context 'alert message' do
        specify { expect(flash[:alert]).to eql "Your offer must be positive." }
      end
    end

    context 'when amount is higher than product price' do
      let!(:product) { create :product, user: seller, price: 1000 }
      let(:amount) { 2000 }
      before { subject }

      specify { expect(response).to redirect_to(:back) }
      context 'alert message' do
        specify { expect(flash[:alert]).to eql "Your offer couldn't be higher than current buy price." }
      end
    end

    context 'when amount has comma' do
      let(:amount) { '100,50' }
      before { subject }

      specify { expect(Offer.first.amount.to_f).to eql 100.5 }
    end

    context 'when wrong credit card' do
      before { credit_card.destroy }
      before { subject }

      specify { expect(response).to redirect_to(:back) }
      context 'alert message' do
        xspecify { expect(flash[:alert]).to eql "Please provide correct credit card." }
      end
    end

    context 'when all is fine' do
      specify { expect(subject).to redirect_to(:back) }

      context 'notice message' do
        before { subject }
        specify { expect(flash[:notice]).to eql "Your offer has been placed!" }
      end

      it 'creates offer for current_user' do
        expect { subject }.to change(current_user.offers, :count).from(0).to(1)
      end

      it 'sends email to the seller' do
        expect { subject }.to deliver_mail(OfferMailer, :offer_created)
      end
    end
  end
end
