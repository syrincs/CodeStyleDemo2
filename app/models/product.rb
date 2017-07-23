class Product < ActiveRecord::Base
  extend FriendlyId
  extend Enumerize

  update_index 'products#product', :self

  enumerize :condition, in: [:new, :new_other, :remanufactured, :used, :antique, :custom, :other], scope: true

  friendly_id :friendly_title, use: [:slugged, :finders, :history]

  store_accessor :car_data, :vin, :year, :mileage, :drive_type, :engine, :trim

  belongs_to :user, counter_cache: true
  belongs_to :car_model
  belongs_to :car_make

  belongs_to :ships_from_address, class_name: 'Address'

  has_one :categorization, dependent: :destroy
  has_one :category, through: :categorization, source: :category
  has_one :address, as: :addressable, dependent: :destroy
  has_one :order, dependent: :destroy
  has_many :offers
  has_many :transactions
  has_many :activities, as: :trackable
  has_many :messages, class_name: 'ProductMessage'
  has_many :notifications, as: :subject
  has_many :questions
  has_many :answers, through: :questions
  has_many :photos, -> { order :position_order }, class_name: 'ProductPhoto'
  has_many :watched_users, class_name: 'WatchList'

  validates :title, presence: { message: 'Enter title of product' }
  validates :categorization, presence: true
  validates :ships_from_address, presence: true
  validates :price, presence: true, numericality: { greater_than: 0, message: 'Please enter product price' }
  validates :price, numericality: { less_than: 100000, message: 'Sorry, but we cannot process payments bigger than $99,999.99' }

  validates :condition, presence: true
  validates :auction_duration, presence: true#, inclusion: { in: [24, 72, 168, 720]}
  validate :minimal_price_valid

  validates :vin, :year, :mileage, :drive_type, :engine, :trim, presence: true, if: :car?
  validates :year, :mileage, numericality: true, if: :car?

  monetize :price_cents
  monetize :original_price_cents
  monetize :highest_offer_amount_cents, allow_nil: true
  monetize :minimal_price_cents

  accepts_nested_attributes_for :address, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :categorization

  scope :search_import, -> { includes(:category, :address, :taggings, :user) }
  scope :with_bids, -> { joins(:offers) }
  scope :with_offers, -> { where('products.offers_count > 0') }
  scope :without_offers, -> { where('products.offers_count = 0') }
  scope :sold, -> { where(sold: true) }
  scope :not_sold, -> { where.not(sold: true) }
  scope :for_sale, -> { where(sold: false) }

  scope :hidden, -> { where(hidden: true) }
  scope :not_hidden, -> { where(hidden: false) }
  scope :published, -> { where(published: true) }
  scope :pending, -> { where(published: false) }
  scope :moderating, -> { pending.where(moderated_at: nil) }
  scope :approved, -> { published.where.not(moderated_at: nil)}
  scope :handling, -> {}
  scope :auction_not_finished, -> { where('auction_finish_at >= ?', Time.current) }
  scope :auction_finished, -> { where('auction_finish_at < ?', Time.current) }
  scope :on_sale, -> { not_sold.auction_not_finished }
  scope :ordered, -> { order(created_at: :desc) }

  scope :for_sitemap, -> { where(sold: false, hidden: false).auction_not_finished }

  before_save do
    self.description = Sanitize.fragment(self.description, Sanitize::Config::USERINPUT)
  end

  before_validation on: :create do
    self.original_price_cents = self.price_cents
  end

  after_create do
    self.activities.create text: "Product added"
  end

  before_create do
    self.offers_count = 0
  end

  def free_bid?
    offers.size < 10
  end

  def location
    if ships_from_address
      "#{ships_from_address.city}, #{ships_from_address.state}"
    end
  end

  # TODO: move to relation
  alias seller user
  alias seller= user=

  def cached_photos
    JSON.parse(photos_cache) if photos_cache.present?
  end

  def buyer
    order.try(:buyer)
  end

  def pending
    published && sold == false
  end

  def publish!
    self.published = true
    self.save!
  end

  def email_confirm_hash
    Digest::SHA256.hexdigest("#{self.user.salt}#{self.created_at.to_i}#{self.user.email}#{self.user.salt}".gsub(/a/, 'x')).gsub(/a/, 'x')
  end

  # Grabbing highest offer, first created
  def highest_offer
    self.offers.order('amount_cents DESC, created_at ASC').where('accepted is NULL or accepted=?', true).first
  end

  def accepted_offer
    self.offers.where(accepted: true).first
  end

  def editable?
    self.offers.size == 0
  end

  def auction_duration
    (self.auction_finish_at.to_i - self.created_at.to_i)/60/60 if self.auction_finish_at.present?
  end

  def auction_duration_days
    auction_duration / 24 if self.auction_finish_at.present?
  end

  def auction_duration=hours_amount
    self.auction_finish_at = hours_amount.to_i.hours.from_now(self.created_at || Time.now)
  end

  def discount
    (self.original_price - self.price)/self.original_price
  end

  def discount_percentage
    ((original_price - price) / original_price).round(2)
  end

  def sku
    "#{slug}-#{id}"
  end

  def update_original_price?
    offers_count.zero? && price.to_f < original_price.to_f
  end

  def auction_hours_to_finish
    (self.auction_finish_at.to_i - Time.current.to_i)/1.hour if self.auction_finish_at.present?
  end

  def place_again!
    update(created_at: Time.current, auction_finish_at: auction_duration_days.days.from_now)
  end

  def notifications_destroy_all
    notifications.destroy_all
  end

  def minimal_price_valid
    if minimal_price >= original_price
      errors.add(:minimal_price, 'can\'t be more than Buy Now Price')
    end
    if minimal_price > original_price * 0.3
      errors.add(:minimal_price, "should be less than $#{original_price * 0.3}")
    end
  end

  def friendly_ships_from
    [ships_from_address.state, ships_from_address.city].delete_if(&:blank?).join('-')
  end

  def friendly_title
    [
      [:manufacturer, :title],
      [:manufacturer, :title, :friendly_ships_from],
      [:manufacturer, :title, :friendly_ships_from, :id]
    ]
  end

  def car?
    return unless categorization.try(:category)
    categorization.category.code == 'automotive-parts-cars'
  end
end
