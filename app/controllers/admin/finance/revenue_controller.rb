class Admin::Finance::RevenueController < Admin::BaseController
  def index
  end

  private

  def authorize_user
    authorize! :read, :finance
  end
end
