class Admin::OrdersController < Admin::BaseController
  decorates_assigned :orders

  def search
    query = ["shipping_tracking_number LIKE :q OR products.title LIKE :q OR products.description LIKE :q", q: "%#{params[:q]}%"]
    @orders = Order.joins(:product).where(query).page(params[:page])
    render :index
  end

  def index
    @orders = Order.ordered.real.includes(:user, product: :user).page(params[:page])
  end

  private

  def authorize_user
    authorize! :manage, Order
  end
end
