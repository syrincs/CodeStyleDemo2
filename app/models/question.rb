class Question < ActiveRecord::Base
  belongs_to :product
  belongs_to :user

  has_one :answer

  validates :title, presence: { message: 'Enter title of question' }
  validates :description, presence: { message: 'Enter description of question' }

  scope :by_user, -> (id) { where(products: { user_id: id }) }

  scope :answered, -> { includes(:answer).where.not(answers: { id: nil }) }
  scope :not_answered, -> { includes(:answer).where(answers: { id: nil }) }
end