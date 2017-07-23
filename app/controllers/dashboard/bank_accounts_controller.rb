class Dashboard::BankAccountsController < ApplicationController
  before_filter :require_login

  def new
    @bank_account = current_user.bank_accounts.build
  end

  def create
    @bank_account = current_user.bank_accounts.build(bank_account_params)

    ActiveRecord::Base.transaction do
      @bank_account.save!
      @bank_account.create_in_stripe!(request)
    end

    redirect_to dashboard_payment_details_path, flash: {success: 'Bank account has been successfully saved'}
  rescue ActiveRecord::RecordInvalid
    render "new"
  rescue StandardError => e
    raise e if Rails.env.development?
    Rollbar.log(e)
    flash.now[:alert] = e.message
    render "new"
  end

  def destroy
    bank_account = current_user.bank_accounts.find(params[:id])
    bank_account.destroy
    redirect_to dashboard_payment_details_path, flash: {success: 'Bank account has been successfully deleted'}
  end

  def make_default
    ba = current_user.bank_accounts.find(params[:id])
    ba.make_default!

    render json: {message: 'success'}
  end

  private

  def bank_account_params
    params.require(:bank_account).permit(
      :routing_number,
      :account_number,
      :name_on_account,
      :bank_name,
      :address,
      :phone_number,
      :phone_number,
      :legal_entity_address1,
      :legal_entity_city,
      :legal_entity_postal_code,
      :legal_entity_state,
      :legal_entity_ssn_last_4,
      :default
    )
  end
end
