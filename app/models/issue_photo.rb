class IssuePhoto < ActiveRecord::Base
  mount_uploader :filename, IssuePhotosUploader

  validates :filename, presence: true

  def to_s
    filename.url(:thumbnail)
  end
end
