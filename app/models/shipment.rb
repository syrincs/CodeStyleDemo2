class Shipment < ActiveRecord::Base
  belongs_to :shippable, inverse_of: :shipment, polymorphic: true

  def parcel_attributes
    attributes.slice(*%w(width height length weight))
  end
end
