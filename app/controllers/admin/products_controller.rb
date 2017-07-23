class Admin::ProductsController < Admin::BaseController
  decorates_assigned :products
  decorates_assigned :product
  before_action :assign_product, only: [:edit, :update, :mark_featured, :unmark_featured, :prolong]

  def search
    query = ["title LIKE :q OR description LIKE :q", q: "%#{params[:q]}%"]
    @products = Product.where(query).page(params[:page])
    render :index
  end

  def index
    @products = Admin::ProductsSearch.new(params).search
  end

  def edit
  end

  def prolong
    @product.update(auction_finish_at: 90.days.from_now)
    redirect_to :back
  end

  def mark_featured
    ProductCreationManager.new(current_user).mark_featured(@product)
    redirect_to :back
  end

  def unmark_featured
    ProductCreationManager.new(current_user).unmark_featured(@product)
    redirect_to :back
  end

  def update
    ProductCreationManager.new(current_user).update_product(@product, params)
    redirect_to action: :index
  rescue ProductCreationManager::ValidationError => e
    render :edit, alert: e.message
  end

  def destroy
    product = Product.friendly.find(params[:id])
    authorize! :delete, product
    ProductCreationManager.new(current_user).hide_product(product)
    redirect_to action: :index
  rescue ProductCreationManager::ValidationError => e
    redirect_to :back, alert: e.message
  end

  private

  def check_role!
    raise ActiveRecord::RecordNotFound unless Role::ROLES.include?(params[:role])
  end

  def assign_product
    @product = Product.friendly.find(params[:id])
  end

  def authorize_user
    authorize! :manage, Product
  end

  def product_params
    params.require(:product).permit(
      :title,
      :description,
      categorization_attributes: [:id, :name, :category_id],
      photos: []
    )
  end
end
