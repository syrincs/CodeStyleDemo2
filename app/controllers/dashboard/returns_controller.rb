class Dashboard::ReturnsController < ApplicationController
  before_filter :require_login
  before_filter :assign_order

  decorates_assigned :order, :issue

  def received
    @issue = @order.issue
    @order.update_attributes! status: :returned
    @order.activities.create! text: 'Item returned to the seller'
    @issue.activities.create! text: 'Item returned to the seller'
    @issue.activities.create! text: 'Bank transaction was voided'
    @issue.activities.create! text: 'Issue closed'
    redirect_to dashboard_store_order_path @order
  end

  def create
    @issue = Issue.new(issue_params)

    order_lifecycle_manager.create_returning_issue(@issue)
    redirect_to dashboard_order_return_path(@order)
  rescue OrderLifecycleManager::ValidationError => e
    flash.now[:alert] = e.message
    render 'new'
  end

  def show
    @issue = @order.issue
  end

  def new
    @subjects = Issue::RETURNING_REASONS
    @issue = Issue.new
  end

  def edit
    @issue = @order.issue
    render 'new'
  end

  def update
    @issue = @order.issue
    if @issue.update_attributes(issue_params)
      redirect_to dashboard_order_return_path(@order)
    else
      render 'new'
    end
  end

  private

  def assign_order
    @order = Order.find(params[:order_id])
  end

  def issue_params
    params[:issue].permit(:subject, :description, photos_attributes: [:filename])
  end

  def order_lifecycle_manager
    OrderLifecycleManager.new(@order, current_user)
  end
end
