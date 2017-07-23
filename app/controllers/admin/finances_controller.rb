class Admin::FinancesController < Admin::BaseController
  decorates_assigned :orders

  def search
  end

  def index

  end

  private

  def authorize_user
    authorize! :read, :finance
  end
end
