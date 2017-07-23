class Admin::DashboardController < Admin::BaseController
  def index
    @analytics = Admin::OrdersDashboardAnalytics.new
    @revenue_analytics = Admin::RevenueAnalytics.new
  end

  private

  def authorize_user
    authorize! :read, :admin_dashboard
  end
end
