class Charge < ActiveRecord::Base
  extend Enumerize

  update_index 'orders#order', :order
  update_index 'offers#offer', :offer

  # if offer_id specified - than we know this charge for offer
  # otherwise we decided this charge for product

  belongs_to :order
  belongs_to :user
  belongs_to :offer
  has_many :transactions, as: :transactionable

  enumerize :status, in: { created: 0, success: 1, failed: -1 }, scope: true, default: :created
  monetize :amount_cents
end
