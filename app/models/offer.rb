class Offer < ActiveRecord::Base
  BIDDING_FEE = 2 # dollars
  PRICE_PER_BID_IN_CENTS = 200 # amount the user will have to pay
  BIDDING_FEE_IN_CENTS = 100 # amount the seller will get (rest should go to 1bid1)

  update_index 'offers#offer', :self
  update_index 'products#product', :product

  belongs_to :user
  alias_method :buyer, :user
  belongs_to :product, counter_cache: true
  has_one :charge

  monetize :amount_cents

  BIGGER_OFFERS_COUNT = <<-SQL
    SELECT COUNT(*) FROM offers AS o
    WHERE o.product_id = offers.product_id AND o.amount_cents >= offers.amount_cents AND o.id != offers.id
  SQL

  scope :wins, -> { where "(#{BIGGER_OFFERS_COUNT}) = 0" }
  scope :outbid, -> { where "(#{BIGGER_OFFERS_COUNT}) > 0" }

  scope :ordered,      -> { order(created_at: :desc) }
  scope :paid,         -> { where(free: false) }
  scope :free,         -> { where(free: true) }
  scope :accepted,     -> { where(accepted: true) }
  scope :not_accepted, -> { where(accepted: false) }
  scope :pending,      -> { where(accepted: nil) }
  scope :not_rejected, -> { where(arel_table[:accepted].eq(true).or(arel_table[:accepted].eq(nil))) }

  after_create do
    self.product.activities.create text: "Placed bid $#{self.amount}" if self.product
  end

  delegate :seller, to: :product

  def is_highest_offer?
    self.class.wins.where(id: id).exists?
  end

  def self.powerbid
    self.count
  end
end
