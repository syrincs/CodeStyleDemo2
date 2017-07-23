class Dashboard::MessagesController < ApplicationController
  before_filter :require_login
  before_filter :assign_message, only: [:show, :reply]
  before_filter :assign_product, only: [:create, :new]
  helper_method :scope

  def index
    @messages = messages_for_scope
  end

  def create
    MessageCreationManager.new(current_user).create_for_product(@product, params[:product_message])
    redirect_to dashboard_orders_path, notice: 'Message has been successfully sent'
  end

  def new
    if @product.seller == current_user
      @message = ProductMessage.new(product: @product, sender: current_user, recipient: @product.buyer)
    end
    if @product.buyer == current_user
      @message = ProductMessage.new(product: @product, sender: current_user, recipient: @product.seller)
    end
  end

  def show
  end

  def reply
    MessageCreationManager.new(current_user).reply(@message, params[:message])
    redirect_to :back, notice: 'Message has been successfully sent'
  end

  private

  def assign_message
    @message = ProductMessage.includes(:sender).find(params[:id])
  end

  def assign_product
    @product = Product.find(params[:product_id])
  end

  def scope
    params[:scope].presence || 'inbox'
  end

  def messages_for_scope
    case
    when scope == 'inbox'
      current_user.received_messages.ordered
    when scope == 'sent'
      current_user.sent_messages.ordered
    end.includes(:product)
  end
end
