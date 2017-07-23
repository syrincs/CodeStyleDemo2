class Dashboard::AddressesController < ApplicationController
  before_filter :require_login
  before_filter :assign_address, only: [:make_default, :update, :edit, :destroy]
  attr_reader :address

  def index
    @addresses = current_user.addresses.decorate
  end

  def new
    @return_to = params[:return_to]
    @address = current_user.addresses.build current_user.attributes.slice('first_name', 'last_name')
  end

  def create
    @address = current_user.addresses.build(address_params)

    if request.xhr?
      if @address.save
        render json: {
           data: @address,
           html: render_to_string(partial: 'products/address.html', layout: false)
         }, status: 200
      else
        render json: {
           errors: @address.errors,
           html: render_to_string(partial: 'products/change_address_modal.html', layout: false)
         }, status: :unprocessable_entity
      end
    else
      if @address.save
        push_event_address_added
        redirect_to after_address_created_path, flash: {success: 'Your address has been successfully saved'}
      else
        render :new
      end
    end
  end

  def edit
    @return_to = params[:return_to]
  end

  def update
    if @address.update address_params
      redirect_to after_address_created_path, flash: {success: 'Your address has been successfully saved'}
    else
      render :edit
    end
  end

  def destroy
    if current_user.addresses.count > 1 && address.destroy
      render json: {message: 'Shipping address has been successfully removed'}
    else
      render json: {message: 'You can\'t delete this address', errors: address.errors}
    end
  end

  def make_default
    address.make_default!
    render json: {message: 'Shipping address has been successfully changed'}
  end

  private

  def after_address_created_path
    case
    when session[:buy_product_id]
      product_path(session.delete(:buy_product_id), to: 'buy-now')
    when session[:make_offer_product_id]
      product_path(session.delete(:make_offer_product_id), to: 'make-offer')
    else
      params.fetch(:return_to) { session.delete(:return_to).presence || addresses_path }
    end
  end

  def assign_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(
      :first_name,
      :last_name,
      :address1,
      :address2,
      :state,
      :location,
      :zip_code,
      :city,
      :default_address
    )
  end

  def push_event_address_added
    push_to_data_layer_later event: 'VirtualPageview',
                             virtualPageURL: '/address_added',
                             virtualPageTitle: 'virturl: Address added'
  end
end
