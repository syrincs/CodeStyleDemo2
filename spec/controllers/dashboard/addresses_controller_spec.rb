require 'rails_helper'

RSpec.describe Dashboard::AddressesController do
  render_views

  let!(:user) { create :user }
  let!(:address) { create :address, addressable: user }
  before { login_user user }

  describe 'GET index' do
    let!(:address_of_another) { create :address }

    before { get :index }

    it 'assigns @addresses' do
      expect(assigns(:addresses)).to include address
    end

    it 'does not include address of another' do
      expect(assigns(:addresses)).not_to include address_of_another
    end

    it 'renders index template' do
      expect(response).to have_rendered('index')
      expect(response.body).not_to be_empty
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'assigns @address' do
      expect(assigns(:address)).to be_a Address
      expect(assigns(:address)).to be_new_record
    end

    it 'renders new template' do
      expect(response).to have_rendered('new')
      expect(response.body).not_to be_empty
    end
  end

  describe 'POST create' do
    let(:attributes) { attributes_for(:address) }
    before { post :create, address: attributes }

    it 'creates an address' do
      expect(Address.find_by(attributes)).to be_present
    end

    it 'redirects to :index' do
      expect(response).to redirect_to(action: :index)
    end

    context 'with default_address: true' do
      let(:attributes) { attributes_for(:address, default_address: true) }

      it 'makes address default' do
        expect(user.addresses.where(default_address: true)).to have(1).item
        expect(user.addresses.find_by(default_address: true)).to eql assigns(:address)
      end
    end

    context 'with wrong attributes' do
      let(:attributes) { {first_name: ''} }

      it 'renders :new' do
        expect(response).to have_rendered('new')
        expect(response.body).not_to be_empty
      end
    end
  end

  describe 'GET edit' do
    before { get :edit, id: address.id }

    it 'assigns @address' do
      expect(assigns(:address)).to eql address
    end

    it 'renders edit template' do
      expect(response).to have_rendered('edit')
      expect(response.body).not_to be_empty
    end
  end

  describe 'PUT update' do
    let(:new_attributes) { attributes_for(:address).stringify_keys }
    before { put :update, id: address.id, address: new_attributes }

    it 'updates the address' do
      expect(address.reload.attributes).to include new_attributes
    end

    it 'redirects to :index' do
      expect(response).to redirect_to(action: :index)
    end

    context 'with wrong attributes' do
      let(:new_attributes) { {first_name: ''} }

      it 'renders :edit' do
        expect(response).to have_rendered('edit')
        expect(response.body).not_to be_empty
      end
    end
  end

  describe 'DELETE destroy' do
    before { delete :destroy, id: address.id }

    it 'destroys the address' do
      expect { address.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'renders message in json' do
      expect(response.body).to eql({message: 'Shipping address has been successfully removed'}.to_json)
    end
  end

  describe 'PUT make_default' do
    before { put :make_default, id: address.id }

    it 'makes the address default' do
      expect(address.reload).to be_default_address
      expect(user.addresses.where(default_address: true)).to have(1).item
    end

    it 'renders message in json' do
      expect(response.body).to eql({message: 'Shipping address has been successfully changed'}.to_json)
    end
  end
end
