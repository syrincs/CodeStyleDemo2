class Dashboard::OrdersController < ApplicationController
  before_filter :require_login

  def index
    @orders = current_user.orders

    params[:scope] = 'all' if params[:scope].blank?

    case params[:scope]
    when 'open'
      @orders = @orders.created
    when 'paid'
      @orders = @orders.paid
    when 'delivered'
      @orders = @orders.delivered
    when 'cancelled'
      @orders = @orders.none # don't implemented yet
    end

    @orders = @orders.includes(product: [:user]).page(params[:page])
  end

  def show
    @order = current_user.orders.find(params[:id]).decorate
  end

  def received
    @order = current_user.orders.find(params[:id])
    OrderLifecycleManager.new(@order, current_user).order_received

    flash[:notice] = 'Order has been marked as received'
    respond_to do |format|
      format.json { render json: { } }
    end
  end

  def purchase
    order = current_user.orders.find(params[:id])
    return if redirect_if_no_buyer_address!(order)

    credit_card = find_or_create_credit_card
    order_lifecycle_manager = OrderLifecycleManager.new(order, current_user)
    order_lifecycle_manager.order_purchase(credit_card, params[:credit_card][:verification_value], request)

    redirect_to dashboard_order_path(order), notice: "You have just purchased order ##{order.public_id}"
  rescue OrderLifecycleManager::ValidationError => e
    redirect_to :back, flash: { alert: e.message }
  end

  def cancel
    order = current_user.orders.find(params[:id])
    return if redirect_if_no_buyer_address!(order)

    OrderLifecycleManager.new(order, current_user).order_cancel

    redirect_to dashboard_orders_path, notice: "You have just canceled order ##{order.public_id}"
  rescue OrderLifecycleManager::ValidationError => e
    redirect_to :back, flash: { alert: e.message }
  end

  private

  def find_or_create_credit_card
    if credit_card_params[:id]
      current_user.credit_cards.find_by(id: credit_card_params[:id])
    else
      StripeBillingManager.new(current_user).create_credit_card(credit_card_params)
    end
  end

  def redirect_if_no_buyer_address!(order)
    if order.buyer.address.blank?
      redirect_to new_address_path(return_to: dashboard_order_path(order)), alert: 'Please add your shipping address first'
    end
  end

  def credit_card_params
    params.require(:credit_card).permit(:id, :credit_card_params, :brand, :display_number, :name, :stripe_token, :month, :year, :verification_value)
  end
end
