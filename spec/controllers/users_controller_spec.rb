require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:params) { {user: attributes_for(:user).slice(:email, :password, :first_name, :last_name)} }

  context 'POST create' do
    it 'returns json' do
      post :create, params.merge(format: :json)
      expect(response).to have_http_status(:ok)
      expect(response.body).to eql({message: 'success', destination_url: nil}.to_json)
    end
    it 'returns a destination URL if provided' do
      post :create, params.merge(format: :json, destination_url: "/go/to/me")
      expect(response).to have_http_status(:ok)
      expect(response.body).to eql({message: 'success', destination_url: "/go/to/me"}.to_json)
    end
    it 'creates a user' do
      expect { post :create, params.merge(format: :json) }
        .to change(User, :count).by(1)
    end
    it 'responds only to json' do
      expect { post :create, params }.to raise_error ActionController::UnknownFormat
    end
  end
end
