class GuestUser
  class ValidationError < StandardError
  end

  attr_accessor :email, :password, :credit_card

  def initialize(email, credit_card_params)
    @email = email
    @password = generate_password
    @credit_card_params = credit_card_params
    @user = User.new(email: @email, password: @password)
    raise ValidationError, 'Email is not valid' unless EmailValidator.valid?(@email.to_s)
  end

  def promote_to_user
    @user.tap do |u|
      raise ValidationError, 'Email is already taken' if User.where(email: @email).present?
      u.save(validate: false)
      StripeBillingManager.new(u).create_customer_profile
      create_credit_card
    end
  end

  private

  def create_credit_card
    raise ValidationError, 'Please select a payment method' if @credit_card_params.blank?
    @credit_card = StripeBillingManager.new(@user).create_credit_card(@credit_card_params)
  end

  def generate_password
    SecureRandom.hex
  end
end
