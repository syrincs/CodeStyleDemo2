class Forms::Base
  include ActiveModel::Model

  class_attribute :attributes, :target
  self.attributes = []

  def self.def_target(target)
    self.target = target
    attr_reader target
  end

  def self.def_attributes(*attributes)
    self.attributes |= attributes
    delegate(*attributes, to: "@#{self.target}")
    delegate(*attributes.map { |attr| "#{attr}=" }, to: "@#{self.target}")
  end

  def target
    instance_variable_get :"@#{self.class.target}"
  end

  def attributes=(attributes)
    attributes.each do |key, value|
      target.send("#{key}=", value) if target.respond_to?("#{key}=")
      send("#{key}=", value) if respond_to?("#{key}=")
    end
  end

  def validate!
    !valid? && raise(ActiveRecord::RecordInvalid.new(self))
  end
end
