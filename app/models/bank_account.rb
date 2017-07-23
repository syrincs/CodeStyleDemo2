class BankAccount < ActiveRecord::Base
  belongs_to :user

  scope :ordered, -> { order(created_at: :desc) }

  validates :name_on_account, presence: true
  validates :routing_number, presence: true, :format => { :with => /\A[0-9]{9}\Z/ }
  validates :account_number, presence: true
  validates :address, presence: true
  validates :phone_number, presence: true

  validates :legal_entity_state, presence: true
  validates :legal_entity_city, presence: true
  validates :legal_entity_address1, presence: true
  validates :legal_entity_ssn_last_4, presence: true, :format => { :with => /\A[0-9]{4}\Z/ }
  validates :legal_entity_postal_code, presence: true

  after_create :update_default_bank_account

  # FIXME: this should go in a before save and we should make stripe_bank_account_id required field
  def create_in_stripe!(client_request)
    stripe_account = self.user.create_or_update_managed_stripe_account!(client_request)

    # update Stripe account's Legal Entity info with whatever we received here
    # FIXME: this whole flow, and which forms go where should be redesigned
    # as discussed with Jurgen, this whole flow/design should be optimized someday..
    stripe_account.legal_entity.ssn_last_4 = legal_entity_ssn_last_4
    stripe_account.legal_entity.address.line1 = legal_entity_address1
    stripe_account.legal_entity.address.city = legal_entity_city
    stripe_account.legal_entity.address.postal_code = legal_entity_postal_code
    stripe_account.legal_entity.address.state = legal_entity_state
    stripe_account.save

    # create bank account in Stripe
    api_params = {
      :external_account => {
        :object => "bank_account",
        :account_holder_name => name_on_account,
        :account_number => account_number,
        :account_holder_type => "individual",
        :country => "US",
        :currency => "usd",
        :default_for_currency => default?,
        :routing_number => routing_number,
        metadata: {
          :address => address,
          :phone_number => phone_number,
          :local_user_id => user.id,
          :user_ip => client_request.remote_ip
        }
      }
    }
    stripe_bank_account = stripe_account.external_accounts.create(api_params)
    update_attributes!(stripe_bank_account_id: stripe_bank_account.id)
  end

  def to_s
    "account #{account_number}"
  end

  def make_default!
    old = self.user.default_bank_account

    if old != self
      old.update_column :default, false if old.present?
      self.update_column :default, true
    end
  end

  after_destroy do
    if self.default? && self.user.bank_accounts.size > 0
      self.user.bank_accounts.first.make_default!
    end
  end

  def update_default_bank_account
    # if bank account saved as default, update all ofter user's bank account to be not default if have some
    self.user.bank_accounts.where('id != ?', self.id).update_all(default: false) if self.default?
    update_column(:default, true) if self.user.bank_accounts.size <= 1
  end

end
