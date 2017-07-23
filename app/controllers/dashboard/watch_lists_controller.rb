class Dashboard::WatchListsController < ApplicationController
  before_filter :require_login
  before_filter :authorize_user

  def index
    @watch_lists = current_user.watch_lists.includes(:product).page(params[:page])
  end

  def create
    current_user.update_attribute :phone_number, params[:phone_number] if params[:phone_number].present?

    product = Product.find(params[:product_id])
    WatchList.find_or_create_by(product: product, user: current_user)
    notice = 'Added to your <a href="/dashboard/watch_lists">Watch list</a>'
    if params[:return_to].present?
      redirect_to params[:return_to], notice: notice
    else
      redirect_to product_path(product), notice: 'Added to your <a href="/dashboard/watch_lists">Watch list</a>'
    end
  end

  def destroy
    list = WatchList.find(params[:id])
    authorize! :manage, list
    list.destroy
    notice = 'Removed from your <a href="/dashboard/watch_lists">Watch list</a>'
    if params[:return_to].present?
      redirect_to params[:return_to], notice: notice
    else
      redirect_to product_path(list.product), notice: notice
    end
  end

  private

  def authorize_user
    authorize! :manage, WatchList
  end

  def require_login
    if !logged_in?
      session[:return_to_url] = product_path(params[:product_id])
      self.send(Config.not_authenticated_action)
    end
  end
end
