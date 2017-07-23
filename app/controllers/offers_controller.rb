class OffersController < ApplicationController

  def accept_offer
    offer = Offer.find(params[:id])
    order = AuctionLifecycleManager.new(offer.product, current_user).accept_offer(offer)

    respond_to do |format|
      format.html { redirect_to dashboard_store_order_path(order), notice: 'Offer has been accepted'}
      format.json { render json: {message: 'Offer has been accepted', redirect: dashboard_store_order_path(order)} }
    end

  rescue AuctionLifecycleManager::ValidationError => e
    respond_to do |format|
      format.html { redirect_to :back, alert: e.message }
      format.json { render json: {message: e.message, errors: e.errors}, status: :unprocessable_entity }
    end
  end

  private

  def offer_params
    params.require(:offer).permit(:amount, :accepted)
  end
end
