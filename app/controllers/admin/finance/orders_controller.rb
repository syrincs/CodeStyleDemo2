class Admin::Finance::OrdersController < Admin::BaseController
  def index
    @analytics = Admin::OrdersDashboardAnalytics.new
  end

  private

  def authorize_user
    authorize! :read, :finance
  end
end
