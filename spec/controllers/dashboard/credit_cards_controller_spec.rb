require 'rails_helper'

RSpec.describe Dashboard::CreditCardsController, stripe: true do
  render_views

  let!(:user) { create :user }
  let!(:credit_card) { create :credit_card, user: user }
  before { login_user user }
  before { StripeBillingManager.new(user).create_customer_profile force: true }

  describe 'GET new' do
    before { get :new }

    it 'assigns @credit_card' do
      expect(assigns(:credit_card)).to be_a CreditCard
      expect(assigns(:credit_card)).to be_new_record
    end

    it 'renders new template' do
      expect(response).to have_rendered('new')
      expect(response.body).not_to be_empty
    end
  end

  describe 'POST create' do
    let(:attributes) { attributes_for(:raw_stripe_credit_card) }

    it 'creates an credit_card' do
      expect { post :create, credit_card: attributes }.to change(CreditCard, :count).from(1).to(2)
    end

    it 'redirects to dashboard_payment_details_path' do
      post :create, credit_card: attributes
      expect(response).to redirect_to(dashboard_payment_details_path)
    end

    context 'with default_card: true' do
      let(:attributes) { attributes_for(:raw_stripe_credit_card, default_card: true) }
      before { post :create, credit_card: attributes }

      it 'makes credit_card default' do
        expect(user.credit_cards.where(default_card: true)).to have(1).item
        expect(user.credit_cards.find_by(default_card: true)).to eql assigns(:credit_card)
      end
    end

    context 'with wrong attributes' do
      let(:attributes) { {first_name: ''} }
      before { post :create, credit_card: attributes }

      it 'redirects to :new' do
        expect(response).to redirect_to action: :new
      end
    end
  end

  describe 'DELETE destroy' do
    before { create :credit_card, user: user }
    subject { delete :destroy, id: credit_card.id }

    it 'destroys the credit_card' do
      subject
      expect { credit_card.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'renders message in json' do
      expect(subject).to redirect_to :back
    end
  end

  describe 'PUT make_default' do
    before { create :credit_card, user: user, default_card: true }
    before { put :make_default, id: credit_card.id }

    it 'makes the credit_card default' do
      expect(credit_card.reload).to be_default_card
      expect(user.credit_cards.where(default_card: true)).to have(1).item
    end

    it 'renders message in json' do
      expect(response.body).to eql({message: 'success'}.to_json)
    end
  end
end
