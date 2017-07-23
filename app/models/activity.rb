class Activity < ActiveRecord::Base
  belongs_to :trackable, polymorphic: true

  default_scope -> { order(created_at: :desc) }
end
