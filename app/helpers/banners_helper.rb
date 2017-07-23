module BannersHelper
  def banner(dir, image, action, alt)
    link_to action do
      content_tag :picture do
        banner_source("#{dir}/responsive/#{image}.jpg", width: 1024) +
        banner_source("#{dir}/mobile/#{image}.jpg", width: 320) +
        banner_img("#{dir}/responsive/#{image}.jpg", alt: alt)
      end
    end
  end

  def banner_for_user(image, alt:, action:)
    banner('banners/signed_in', image, action, alt)
  end

  def banner_for_guest(image, alt:, action:)
    banner('banners', image, action, alt)
  end

  def banner_source(image, width:)
    content_tag :source, ' ', srcset: asset_path(image), media: "(min-width: #{width}px)"
  end

  def banner_img(image, alt:)
    content_tag :img, ' ', srcset: asset_path(image), alt: alt
  end
end