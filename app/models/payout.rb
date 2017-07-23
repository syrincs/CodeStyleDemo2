class Payout < ActiveRecord::Base
  extend Enumerize

  belongs_to :order
  has_many :transactions, as: :transactionable

  scope :system, -> { where(destination: 'system') }
  scope :seller, -> { where(destination: 'seller') }

  enumerize :status, in: { created: 0, success: 1, failed: -1 }, scope: true, default: :created
  monetize :amount_cents
end
