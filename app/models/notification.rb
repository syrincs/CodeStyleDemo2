class Notification < ActiveRecord::Base
  belongs_to :subject, polymorphic: true
end
