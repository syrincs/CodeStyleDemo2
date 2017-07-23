class CreditCard < ActiveRecord::Base
  belongs_to :user

  default_scope { order(default_card: :desc, created_at: :desc) }

  has_one :address, as: :addressable, dependent: :destroy

  accepts_nested_attributes_for :address

  after_create do
    self.user.credit_cards.where.not(id: id).update_all(default_card: false) if self.default_card?
  end

  def brand
    self[:brand].to_s.downcase
  end

  def to_s
    "#{brand.humanize if brand} #{display_number}"
  end

  def expiration_date
    "#{month < 10 ? "0#{month}" : month}/#{year}"
  end

  def make_default!
    current_default = self.user.credit_cards.where(default_card: true).first

    if current_default != self
      current_default.update_column :default_card, false if current_default.present?
      self.update_column :default_card, true
    end
  end
end
