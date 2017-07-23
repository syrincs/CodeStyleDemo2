class ProductPhoto < ActiveRecord::Base

  mount_base64_uploader :filename, ProductPhotosUploader

  validates :filename, presence: true

  delegate :url, :cached?, :cache_path, to: :filename

  def to_s
    self.filename.url(:display)
  end

end
