class Admin::OffersController < Admin::BaseController
  decorates_assigned :offers

  def search
    @offers = Admin::OffersSearch.new(params).search
    render :index
  end

  def index
    @offers = Admin::OffersSearch.new(params).search
  end

  private

  def authorize_user
    authorize! :manage, Offer
  end
end
