class Admin::ModerationController < Admin::BaseController
  before_action :load_resources, only: [:index]
  before_action :load_resource, except: [:index]

  def index
  end

  def approve
    flash[:notice] = 'Successfully updated'
    redirect_to :back
  end

  def message
  end

  def decline
    if @product.update(published: false, published_at: nil, moderated_at: Time.current)
      ProductMailer.decline(@product.id, decline_params[:message]).deliver_now
      flash[:notice] = 'Successfully updated'
    end
    redirect_to admin_moderation_index_path
  end

  private

  def decline_params
    params.permit(:id, :message)
  end

  def load_resource
    @product = Product.friendly.find(params[:id])
  end

  def load_resources
    @products = Product.ordered.page(params[:page])
  end

  def authorize_user
    authorize! :manage, Product
  end
end
