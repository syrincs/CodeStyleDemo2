class Credit < ActiveRecord::Base
  belongs_to :user

  monetize :amount_cents

  # Public: Apply credits to a user's credit record
  #
  # amount_in_cents - amount to credit, in cents
  #
  # Examples
  #
  #   credits.apply_credits!(1000) #-> Credits $10
  #
  # Returns a boolean
  def apply_credits!(amount_in_cents)
    self.amount_cents += amount_in_cents * 100
    self.save!
  end


  # Public: Deducts credits from a user's credit record
  #
  # amount_in_cents - amount to deduct, in cents
  #
  # Examples
  #
  #   credits.deduct_credits!(1000) #-> Deducts $10
  #
  # Returns a boolean
  def deduct_credits!(amount_in_cents)
    return false unless self.amount_cents >= amount_in_cents
    self.amount_cents -= amount_in_cents
    self.save!
  end
end

