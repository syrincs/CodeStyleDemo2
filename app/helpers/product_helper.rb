module ProductHelper
  def render_preload_images_css(product)
    <<-CSS
      body:after {
        content: #{render_images_css(product)};
        display: none;
      }
    CSS
  end

  def render_images_css(product)
    ''.tap do |css|
      product.photos.each do |photo|
        css << "url(#{product.display_photo_url(photo)})"
        css << "url(#{photo.url(:zoom, secure: request.ssl?)})"
      end
    end
  end

  def offers_tooltip(product)
    if product.offers.size
      product.offers.map do |offer|
        user_link = link_to offer.user, user_path(offer.user)
        offer_time = offer.created_at.strftime('%b %d, %Y')
        "#{user_link} bids #{offer.amount} #{offer.amount_currency} at #{offer_time} </br>"
      end.join
    else
      'No bids yet'
    end
  end

  def next_page
    params[:page] ? params[:page].to_i + 1 : 2
  end

  def can_load_more?(products)
    products.respond_to?(:total_pages) && params[:page].to_i < products.total_pages
  end
end
