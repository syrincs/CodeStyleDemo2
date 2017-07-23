class ProductMessage < ActiveRecord::Base
  belongs_to :product
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  scope :for_user, -> (user) { where(arel_table[:sender_id].eq(user.id).or(arel_table[:recipient_id].eq(user.id))) }
  scope :ordered, -> { order(created_at: :desc) }

  validates :body, presence: true

  def to_buyer?
    sender.seller_for?(product)
  end

  def to_seller?
    sender.buyer_for?(product)
  end
end
