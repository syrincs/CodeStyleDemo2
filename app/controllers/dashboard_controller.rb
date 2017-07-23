class DashboardController < ApplicationController
  decorates_assigned :addresses
  before_filter :require_login

  def index
    @products_with_bids = current_user.bidded_products.includes(:ships_from_address, :order, :photos)
    @store_products = current_user.products.for_sale.includes(:ships_from_address)
  end

  def payment_details
    @credit_cards = current_user.credit_cards.reorder(created_at: :desc).decorate
    @bank_accounts = current_user.bank_accounts.reorder(created_at: :desc).decorate
  end

  def billing_address
    @address = current_user.billing_address
    @address = current_user.build_billing_address if @address.blank?
  end

  def billing_address_save
    @address = current_user.billing_address
    @address = current_user.build_billing_address(kind: 'billing_address') if @address.blank?
    @address.attributes = params.require(:address).permit(:first_name, :last_name, :address1, :address2, :city, :state, :zip_code)
    respond_to do |format|
      if @address.save
        format.html { redirect_to dashboard_payment_details_path, notice: 'Billing Address updated' }
      else
        format.html { render action: :billing_address }
      end
    end
  end

  def settings
    @user = current_user
    @user.errors.add :phone_number, 'Please fill phone number' if @user.phone_number.blank?
    @user.errors.add :dob, 'Please fill in your date of birth' if @user.dob.blank?
  end


  ########## Account Settings

  def update_password
    current_password = params['user']['current_password']
    new_password = params['user']['new_password']
    confirm_new_password = params['user']['confirm_new_password']

    error = false

    if new_password != confirm_new_password
      message = 'New password and repeated new password are not identical'
      error = true
    elsif !User.authenticate current_user.email, current_password
      message = 'Current password is wrong'
      error = true
    end

    unless error
      current_user.password = new_password
      current_user.save
      message = 'Password successfully updated'
    end

    respond_to do |format|
      format.json { render json: { message: message }, status: (error ? :unprocessable_entity : nil)}
    end
  end

  def update_settings
    user_params.delete :username if user_params[:username].blank?

    @user = current_user
    # normalize_phone_number!

    respond_to do |format|
      if @user.errors.blank? && current_user.update(user_params)
        format.json { render json: { message: 'Successfully updated' } }
        format.html { redirect_to root_path }
      else
        format.html { render :settings }
      end
    end
  end

  private

  def user_params
    @user_params ||= params.require(:user).permit(
      :username, :first_name, :last_name,
      :bio, :email, :avatar, :cover, :phone_number, :dob
    )
  end

  def normalize_phone_number!
    return if user_params[:phone_number].blank?
    client = Twilio::REST::LookupsClient.new.phone_numbers
    user_params[:phone_number] = client.get(user_params[:phone_number], country_code: params.fetch(:code, 'US')).phone_number
  rescue Twilio::REST::RequestError => e
    @user.errors.add :phone_number, :invalid
  end
end
