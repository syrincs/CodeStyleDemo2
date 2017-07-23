class ProductsController < ApplicationController
  before_filter :require_login, only: [:watch, :unwatch]
  before_filter :set_product, only: [:show, :bid, :buy, :watch, :unwatch]
  attr_reader :product

  def help
    render(nothing: true) and return if params[:check].present?
    Contact.create! params.require(:contact).permit(:phone_number, :details)
  end

  def index
    respond_to do |format|
      format.xml { render 'products' }
    end
  end

  def watch

  end

  def unwatch
    WatchList.find_by(product: @product, user: current_user).delete
    redirect_to product_path(@product), notice: 'Removed from your <a href="/dashboard/watch_lists">Watch list</a>'
  end

  def show
    push_to_data_layer pageCategory: @product.category.name if @product.category
    @similar_products = ProductsSearch.new.similar(@product)
    @address = current_user.addresses.build current_user.attributes.slice('first_name', 'last_name') if logged_in?
    authorize! :read, @product
    @watch_list = WatchList.find_by(product: @product, user: current_user) if logged_in?
  rescue CanCan::AccessDenied
    raise ActiveRecord::RecordNotFound
  end

  def new
    redirect_to_dashboard_if_logged_in!
    @product = Product.new
    @product.build_categorization
  end

  def create
    @product = ProductCreationManager.new(current_user).create_product(params)
    redirect_to product_path(@product), notice: 'Your item will be added after moderation proccess. We will send you an email about it. Thank you for choosing us!'
  rescue ProductCreationManager::ValidationError => e
    @product = e.record
    render :new
  end

  def bid
    offer_amount = params[:offer][:amount].gsub(/,/, '.').to_f
    auction_lifecycle_manager = AuctionLifecycleManager.new(product, current_user)
    if product.free_bid?
      auction_lifecycle_manager.free_bid(offer_amount)
    else
      auction_lifecycle_manager.bid(offer_amount, credit_card, params[:credit_card][:verification_value], request)
    end
    push_event_after_bid
    redirect_to :back, notice: 'Your offer has been placed!'
  rescue AuctionLifecycleManager::ValidationError, StripeBillingManager::ValidationError => e
    Rollbar.log(e)
    redirect_to :back, alert: e.message
  end

  def buy
    auction_lifecycle_manager = AuctionLifecycleManager.new(product, current_user)
    auction_lifecycle_manager.buy(credit_card, params[:credit_card][:verification_value], request)
    push_event_after_buy
    redirect_to dashboard_order_path(product.order), notice: "You have just bought #{product.title}"
  rescue AuctionLifecycleManager::ValidationError, GuestUser::ValidationError => e
    Rollbar.log(e)
    redirect_to :back, alert: e.message
  rescue StripeBillingManager::ValidationError => e
    Rollbar.log(e)
    redirect_to :back, alert: "#{e.message}, please contact us"
  end

  protected

  def redirect_to_dashboard_if_logged_in!
    if current_user.present?
      redirect_to new_dashboard_store_product_path(params)
    else
      session[:return_to_url] = request.fullpath if Config.save_return_to_url && request.get?
      redirect_to login_path, alert: 'Please sign in or register in order to sell products'
    end
  end

  def credit_card
    if logged_in?
      if params[:credit_card].present? && params[:credit_card][:id].present?
        user.credit_cards.find_by(id: params[:credit_card][:id])
      else
        @_created_credit_card ||= StripeBillingManager.new(current_user).create_credit_card(params[:credit_card])
      end
    else
      user.credit_cards.first
    end
  end

  def user
    @user ||= current_user || GuestUser.new(params[:email], params[:credit_card]).promote_to_user
  end

  def set_product
    @product = Product.includes(:user, :category, :ships_from_address, questions: [:answer, :user]).friendly.find(params[:id])
    # If an old id or a numeric id was used to find the record, then
    # the request path will not match the post_path, and we should do
    # a 301 redirect that uses the current friendly id.
    if request.get? && @product.category && request.path != category_product_path(@product.category, @product)
      return redirect_to category_product_path(@product.category, @product), status: :moved_permanently
    end
  end

  def push_event_after_buy
    products = [{sku: product.sku,
                 name: product.title,
                 category: product.category.try(:name),
                 price: product.price.to_f,
                 quantity: 1}]

    push_to_data_layer_later pageType: 'ThankYou',
                             transactionId: product.order.public_id,
                             transactionAffiliation: product.seller.id,
                             transactionTotal: product.order.charge.amount.to_f,
                             transactionShipping: 0,
                             transactionProducts: products
  end

  def push_event_after_bid
    push_to_data_layer_later event: 'VirtualPageview',
                             virtualPageURL: "/make_offer/funnel/step2/#{product.slug}",
                             virtualPageTitle: 'virturl: Make offer – Step 2'
  end
end
