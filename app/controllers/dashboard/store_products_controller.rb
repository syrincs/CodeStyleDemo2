class Dashboard::StoreProductsController < ApplicationController
  include AuctionHelper

  before_filter :require_login

  def place_again
    @product = Product.friendly.find(params[:id])
    @product.place_again!
    @product.notifications_destroy_all
    redirect_to :back, notice: 'The item has been placed again'
  end

  def index
    @products = current_user.products.not_hidden.includes(:ships_from_address)

    @scope = params.fetch(:scope, 'all')

    case params[:scope]
    when 'onsale'
      @products = @products.not_sold
    when 'sold'
      @products = @products.sold
    end

    @products = @products.page(params[:page])
  end

  def show
    @product = Product.friendly.find(params[:id])
    authorize! :control, @product
  end

  def new
    return redirect_to_fill_phone_page unless current_user.phone_number.present?
    return redirect_to_fill_dob_page unless current_user.dob.present?

    if current_user.addresses.blank?
      return_path = url_for(params.merge(only_path: true))
      return redirect_to new_address_path(return_to: return_path), notice: 'Please add your shipping location first'
    end

    @product = Product.friendly.new(seller: current_user)
    @product.build_categorization(category_id: params[:category])
  end

  def create
    @product = ProductCreationManager.new(current_user).create_product(params)
    push_event_after_create
    redirect_to product_path(@product), notice: 'Your product has been placed. Thank you for choosing us!'
  rescue ProductCreationManager::ValidationError => e
    @product = e.record
    render :new
  end

  def destroy
    product = Product.friendly.find(params[:id])
    authorize! :delete, product
    ProductCreationManager.new(current_user).hide_product(product)
    if can?(:read, product)
      redirect_to :back
    else
      redirect_to dashboard_store_products_path
    end
  rescue ProductCreationManager::ValidationError => e
    redirect_to :back, alert: e.message
  end

  def edit
    @product = Product.friendly.find(params[:id])
    authorize! :edit, @product
  end

  def update
    @product = Product.friendly.find(params[:id])
    authorize! :edit, @product

    if @product.offers.size > 0 && cannot?(:read, :admin_dashboard)
      redirect_to @product, alert: 'You can\'t edit product'
      return
    end

    ProductCreationManager.new(current_user).update_product(@product, params)

    redirect_to product_path(@product)
  rescue ProductCreationManager::ValidationError => e
    render :edit, alert: e.message
  end

  def upload
  end

  private

  def redirect_to_fill_phone_page
    flash[:notice] = 'Please fill phone number, so we can use it for urgent alerts,
    such as "Your product was sold".'
    redirect_back_or_to dashboard_settings_path
  end

  def redirect_to_fill_dob_page
    flash[:notice] = 'Date of Birth is legal requirement, we cannot transfer money to you without it.'
    redirect_back_or_to dashboard_settings_path
  end

  def product_params
    params.require(:product).permit(
      :title,
      :manufacturer,
      :auction_duration,
      :condition,
      :description,
      :price,
      :minimal_price,
      :ships_from_address_id,
      :car_make_id,
      :car_model_id,
      categorization_attributes: [:id, :name, :category_id],
      photos: []
    )
  end

  def push_event_after_create
    push_to_data_layer_later event: 'VirtualPageview',
                             virtualPageURL: "/add_product/funnel/#{@product.slug}",
                             virtualPageTitle: 'virturl: Add new Product – Final step'
  end
end
