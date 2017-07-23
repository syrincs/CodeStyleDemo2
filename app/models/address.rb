class Address < ActiveRecord::Base
  belongs_to :addressable, polymorphic: true

  default_scope { order(default_address: :desc, created_at: :desc) }

  after_create :update_defaults_if_needed

  after_destroy do
    # TODO: get rid of this shit
    if self.default_address? && self.addressable.class.name != 'Order' && self.addressable.addresses.size > 0
      self.addressable.addresses.first.make_default!
    end
  end

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :address1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip_code, presence: true

  def to_s
    full_address
  end

  def full_address
    "#{address1} #{address2} #{city} #{state} #{zip_code}"
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  # TODO: get rid of this shit
  def make_default!
    current_default = self.addressable.addresses.where(default_address: true).first

    if current_default != self
      current_default.update_column :default_address, false if current_default.present?
      self.update_column :default_address, true
    end
  end

  private

  # TODO: get rid of this shit
  def update_defaults_if_needed
    return unless addressable.respond_to?(:addresses)

    make_default! if addressable.addresses.size == 1
    addressable.addresses.where.not(id: id).update_all(default_address: false) if self.default_address?
  end
end
