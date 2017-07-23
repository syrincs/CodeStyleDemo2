class PromosController < ApplicationController
  CATEGORY_MAPPING = {
    'electronics' => 'electronics',
    'mens_fashion' => 'men-s-fashion',
    'automotive_and_parts'=> 'automotive-parts',
    'womens_fashion'=> 'women-s-fashion',
    'furniture'=> 'home-furniture'
  }

  layout "promos"
  before_action :init_common_view_assigns

  def buyer_category
    @audience = "buyer"
    @products = search.top_in_category(@category).limit(4)
  end

  def seller_category
    @audience = "seller"
    @products = search.top_in_category(@category).limit(4)
  end

  private

  def init_common_view_assigns
    @category_name = params[:category_name]
    @category = Category.find CATEGORY_MAPPING[params[:category_name]]
    @view = "grid"
  end

  def search
    ProductsSearch.new
  end
end
