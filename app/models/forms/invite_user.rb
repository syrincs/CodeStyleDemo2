class Forms::InviteUser < Forms::Base
  attr_accessor :assign_role, :invitation_message

  def_target :user
  def_attributes :first_name, :last_name, :email, :password

  validates :first_name, presence: { message: 'Please enter your first name' }
  validates :last_name, presence: { message: 'Please enter your last name' }
  validates :email, presence: true, email: true
  validate :email_uniqueness

  def initialize(user=User.new, attributes={})
    @user = user
    self.attributes = attributes
  end

  def email_uniqueness
    if User.where(email: email).present?
      errors.add(:email, :taken)
    end
  end
end
