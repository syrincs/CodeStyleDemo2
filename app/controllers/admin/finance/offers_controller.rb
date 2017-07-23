class Admin::Finance::OffersController < Admin::BaseController
  def index

  end

  private

  def authorize_user
    authorize! :read, :finance
  end
end
