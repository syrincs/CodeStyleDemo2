class Dashboard::StoreOrdersController < ApplicationController
  before_filter :require_login
  before_filter :assign_order, except: :index
  attr_reader :order

  def index
    @orders = current_user.store_orders.joins(:product).includes(:product, :user).where.not(user: nil)

    @total_orders = @orders.count

    params[:scope] = 'all' if params[:scope].blank?

    case params[:scope]
    when 'open'
      @orders = @orders.with_status(:created, :not_paid)
    when 'paid'
      @orders = @orders.with_status(:paid)
    when 'shipped'
      @orders = @orders.with_status(:shipped)
    when 'delivered'
      @orders = @orders.with_status(:delivered)
    end

    @orders = @orders.page(params[:page])
  end

  def show
    @order = @order.decorate
    @order.shipment || @order.build_shipment
  end

  def mark_as_shipped
    order_lifecycle_manager.order_shipped params[:order][:shipping_tracking_number]

    respond_to do |format|
      format.html { redirect_to :back, notice: 'Order has been marked as shipped' }
      format.json { render json: {message: 'Order has been marked as shipped'} }
    end
  rescue OrderLifecycleManager::ValidationError => e
    respond_to do |format|
      format.html { redirect_to :back, alert: e.message }
      format.json { render json: {message: e.message}, status: :unprocessable_entity }
    end
  end

  def buy_shipping_label
    order_lifecycle_manager.buy_shipping_label params[:shipment]

    redirect_to dashboard_store_order_path(order), notice: 'Order has been marked as shipped'
  rescue OrderLifecycleManager::ValidationError => e
    flash.now[:alert] = e.message
    render :show
  end

  protected

  def assign_order
    @order = current_user.store_orders.joins(product: :user).includes(:product, :user).find(params[:id])
  end

  def order_lifecycle_manager
    OrderLifecycleManager.new(order, current_user)
  end
end
