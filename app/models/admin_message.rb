class AdminMessage < ActiveRecord::Base
  self.inheritance_column = :none
  belongs_to :user
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  scope :email, -> { where(type: 'email') }
  scope :sms, -> { where(type: 'sms') }
  scope :ordered, -> { order(created_at: :desc) }

  validates :recipient, :body, :type, presence: true
  validates :subject, presence: true, if: -> { type == 'email' }
  validates :body, length: {in: 30..140}, if: -> { type == 'sms' }
  validates :body, length: {in: 30..500}, if: -> { type == 'email' }

  after_initialize do
    self[:type] ||= 'email'
  end

  def max_body_length
    type == 'sms' ? '140' : '500'
  end

  def recipient_address
    if type == 'sms' then
      recipient.phone_number
    else
      recipient.email
    end
  end
end
