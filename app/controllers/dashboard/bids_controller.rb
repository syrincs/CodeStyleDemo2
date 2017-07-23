class Dashboard::BidsController < ApplicationController
  before_filter :require_login
  helper_method :scope

  def index
    @products = products_for_scope
  end

  private

  def scope
    (params[:scope].blank? ? 'all' : params[:scope]).inquiry
  end

  def products_for_scope
    offers = case
    when scope.wins?
      current_user.offers.wins
    when scope.outbid?
      current_user.offers.outbid
    else
      current_user.offers
    end
    Product.where(id: offers.select(:product_id)).includes(:category, order: [:user]).page(params[:page])
  end
end
