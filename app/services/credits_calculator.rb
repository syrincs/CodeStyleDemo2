class CreditsCalculator
  # @param [Integer] price_cents
  # @param [Integer] number_of_offers
  def initialize(price_cents, number_of_offers)
    @price_cents = price_cents
    @number_of_offers = number_of_offers
  end

  # The total amount is the sum of number of offers * $2 and product's price
  # @return [Integer] cents
  def total_amount_cents
    @price_cents + offers_amount_cents
  end

  # Amount of system's share
  # @return [Integer] cents
  def credit_system_cents
    total_amount_cents - credit_seller_cents
  end

  # Amount of seller's share
  # @return [Integer] cents
  def credit_seller_cents
    @price_cents * 0.95 + offers_amount_cents / 2 # 100 cents
  end

  # Basically, we charge $2 per each offer
  # @return [Integer]
  def offers_amount_cents
    @number_of_offers * 200
  end
end
