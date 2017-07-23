class Contact < ActiveRecord::Base
  scope :ordered, -> { order(created_at: :desc) }
end
