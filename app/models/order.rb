class Order < ActiveRecord::Base
  update_index 'orders#order', :self
  update_index 'products#product', :product

  extend Enumerize

  # payment
  # buyer paid for product or not
  # seller received money or not

  # shipped_at == null - not shipped, otherwise - shipped
  # received_at == null - not received buy buyer, otherwise - received

  enumerize :status, in: {created: 0, not_paid: 1, paid: 2, fulfilment: 3, shipped: 4, delivered: 5, returned: 6},
            scope: true, default: :created

  belongs_to :user
  belongs_to :product, autosave: true

  has_one :shipment, inverse_of: :shippable, as: :shippable, autosave: true
  has_one :address, as: :addressable, dependent: :destroy
  has_one :issue
  has_many :activities, as: :trackable

  has_one :charge
  has_many :charges
  has_many :payouts

  monetize :price_cents

  after_save do
    # notify buyer about shipped to him product
    if self.shipped_at_changed? && self.shipped_at_was.blank?
      OrderMailer.shipped_buyer(self.id).deliver_now
    end
  end

  after_create do
    self.activities.create text: "Order placed"
  end

  before_create :set_public_id

  validates :user_id, presence: true
  validates :price_cents, presence: true
  validates :product_id, presence: true

  Order.status.values.each do |status|
    scope status.downcase, -> { with_status(status) }
  end

  scope :not_received, -> { where(received_at: nil) }
  scope :easypost_trackable, -> { where.not(easypost_tracker_id: nil) }
  scope :real, -> { where.not(status: 0) }
  scope :ordered, -> { order(created_at: :desc) }

  # TODO: define association
  def seller
    product.user
  end

  # TODO: define association
  alias buyer user
  alias buyer= user=

  def shipped?
    self.shipped_at.present?
  end

  def self.generate_public_id
    str = []
    4.times {str << rand(0..9)}
    str << '-'
    7.times {str << rand(0..9)}
    str << '-'
    2.times {str << rand(0..9)}
    str.join
  end

  def total
    (self.price.to_f - self.price.to_f * 0.05) + self.product.offers.size
  end

  def purchesed_at
    if charge
      charge.created_at
    end
  end

  #  returns the amount 1bid1 receive as commission
  def platform_fee_cents
    fee = price_cents * 0.05
    fee = 20000 if fee > 20000
    fee.to_i
  end

  private

  def update_public_id
    self.set_public_id
    self.save
  end

  def set_public_id
    while true
      pid = Order.generate_public_id
      break if Order.where(public_id: pid).size == 0
    end
    self.public_id = pid
  end

end
