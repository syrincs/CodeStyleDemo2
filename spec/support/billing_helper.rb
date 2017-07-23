module BillingHelper
  def _billing_manager
    @_billing_manager ||= double('billing manager')
  end

  def stub_billing(performer)
    allow(_billing_manager)
      .to receive(:authorize_and_charge)
      .and_return('charge-token')

    allow(StripeBillingManager)
      .to receive(:new)
      .with(performer)
      .and_return(_billing_manager)

    _billing_manager
  end

  def allow_billing_to_create_credit_card
    allow(_billing_manager)
      .to receive(:create_credit_card)
      .and_return('card-token')
  end

  def allow_billing_to_create_profile
    allow(_billing_manager)
      .to receive(:create_customer_profile)
      .and_return('customer-token')
  end
end

RSpec.configure do |config|
  config.include BillingHelper
end
