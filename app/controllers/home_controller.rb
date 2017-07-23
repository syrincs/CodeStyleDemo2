class HomeController < ApplicationController
  include ProductHelper
  attr_reader :view_type
  before_action :determine_products_view_type

  def index
    @home_view = HomeDecorator.new(self)
    respond_to do |format|
      format.js {
        render json: {
                 paginate: can_load_more?(@home_view.products),
                 view: render_to_string(partial: 'shared/meta/products', layout: false, locals: {products: @home_view.products})
               }
      }

      format.html
    end
  end

  def trending
    @home_view = HomeDecorator.new(self)
    @products = @home_view.trending.per(items_count)
    respond_to do |format|
      format.js {
        render json: {
                 paginate: can_load_more?(@products),
                 view: render_to_string(partial: 'shared/meta/products', layout: false, locals: {products: @products})
               }
      }

      format.html
    end
  end

  def latest
    @home_view = HomeDecorator.new(self)
    @products = @home_view.latest.per(items_count)
    respond_to do |format|
      format.js {
        render json: {
                 paginate: can_load_more?(@products),
                 view: render_to_string(partial: 'shared/meta/products', layout: false, locals: {products: @products})
               }
      }

      format.html
    end
  end

  private

  def items_count
    view_type == 'big_grid' ? 15 : 20
  end

  def determine_products_view_type
    @view = session[:view]
    @view = params[:view] if params[:view].in?(['list', 'grid', 'big_grid'])
    @view ||= 'grid'
    session[:view] = @view
    @view_type = @view
  end
end
