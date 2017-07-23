class Dashboard::StoreReturnsController < ApplicationController
  before_filter :require_login

  decorates_assigned :order, :issue

  def index
    @issues = current_user.store_returns.page(params[:page])
    @total_issues = current_user.store_returns.count
  end

  def show
    @issue = current_user.store_returns.find(params[:id])
    @order = @issue.order
  end
end
