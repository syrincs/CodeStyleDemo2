class Dashboard::CreditCardsController < ApplicationController
  before_filter :require_login
  before_filter :assign_credit_card, only: [:make_default, :destroy]

  def make_default
    @credit_card.make_default!
    render json: {message: 'success'}
  end

  def new
    @credit_card = current_user.credit_cards.build
  end

  def create
    @credit_card = StripeBillingManager.new(current_user).create_credit_card(credit_card_params)
    message = "Your credit card #{@credit_card.display_number} has been successfully saved"
    redirect_to dashboard_payment_details_path, flash: {success: message}
  rescue StripeBillingManager::ValidationError => e
    redirect_to new_credit_card_path, flash: {alert: e.message}
  end

  def destroy
    Billing::CreditCardsManager.new(current_user).destroy @credit_card
    redirect_to :back, notice: 'Card has been successfully deleted!'
  rescue Billing::CreditCardsManager::ValidationError => e
    redirect_to :back, alert: e.message
  end

  private

  def credit_card_params
    params.require(:credit_card).permit(
      :brand,
      :name,
      :display_number,
      :stripe_token,
      :verification_value,
      :month,
      :year,
      :default_card
    )
  end

  def assign_credit_card
    @credit_card = current_user.credit_cards.find(params[:id])
  end
end
