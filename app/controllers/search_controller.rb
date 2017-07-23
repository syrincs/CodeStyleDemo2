class SearchController < ApplicationController
  before_action :products_view, only: [:index, :category]

  def index
    return redirect_to('/automotive-parts') if params[:category] == '1'

    # if search scoped to category
    if params[:category].present?
      @category = Category.find(params[:category])
      session[:data_layer] = [{pageCategory: @category.name}] if @category
    end

    # if search scoped to user
    if params[:user]
      @user = User.find(params[:user])
    end

    @search = ProductsSearch.new(params)
    @products = @search.search
    @car_makes = CarMake.order(:order_position, :name)
  end

  def category
    @category = Category.find(params[:category])
    # If an old id or a numeric id was used to find the record, then
    # the request path will not match the post_path, and we should do
    # a 301 redirect that uses the current friendly id.
    if request.path != category_path(@category)
      return redirect_to category_path(@category), status: :moved_permanently
    end

    session[:data_layer] = [{pageCategory: @category.name}]

    @search = ProductsSearch.new(params)
    @products = @search.search
#   @products = Product.not_sold
#    binding.pry

    @car_makes = CarMake.order(:order_position, :name)
    render :index
  end

  private

  def no_robots?
    Array(params[:condition]).size > 1 ||
      params[:manufacturer].present? ||
      params[:sort].present? ||
      params[:view].present? ||
      params[:page].present? ||
      params[:q].present?
  end

  def meta_robots_content
    if params[:view].present? || params[:page].present?
      'NOINDEX,FOLLOW'
    else
      super
    end
  end

  def products_view
    @view = session[:view]
    @view = params[:view] if params[:view].in?(['list', 'grid', 'big_grid'])
    @view ||= 'grid'
    session[:view] = @view
  end
end
