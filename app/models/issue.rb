class Issue < ActiveRecord::Base
  RETURNING_REASONS = [
    'Missing parts or accessories',
    'Different from what was ordered',
    'Damaged during shipping',
    'Item not as pictured or described',
    'Item defective or does not work',
    'Item expired',
    'Ordered wrong item',
    'Accidentally ordered item',
    'Found better price elsewhere',
    'No longer want / need item',
    'Returning a gift'
  ]
  belongs_to :order

  has_one :buyer, through: :order, source: :user, inverse_of: :issues
  has_one :product, through: :order
  has_one :seller, through: :product, source: :user, inverse_of: :issues

  has_many :photos, class_name: 'IssuePhoto', dependent: :destroy
  has_many :activities, as: :trackable
  has_one :shipment, inverse_of: :shippable, as: :shippable, autosave: true

  accepts_nested_attributes_for :photos, allow_destroy: true, reject_if: -> (attrs) { attrs['filename'].blank? && attrs['filename_cache'].blank? }

  validates :subject, presence: true

  def status
    'Open'
  end

  def can_edit?(user)
    user == order.buyer
  end

  def can_mark_shipped?(user)
    user == order.seller && order.status.delivered?
  end
end
