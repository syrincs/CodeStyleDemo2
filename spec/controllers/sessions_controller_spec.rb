require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:params) { {user: {email: 'user@example.com', password: 'password'}} }

  context 'when user exists' do
    let!(:user) { create :user, email: 'user@example.com', password: 'password' }

    it 'signs in' do
      post :create, params
      expect(response).to redirect_to '/dashboard/settings'
    end
  end

  context 'when user does not exist' do
    it 'does not sign in' do
      post :create, params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template 'new'
    end
  end
end
