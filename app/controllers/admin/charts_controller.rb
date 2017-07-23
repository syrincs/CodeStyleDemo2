class Admin::ChartsController < Admin::BaseController
  def offers_by_date
    authorize! :read, :finance
    histogram = Admin::OrdersDashboardAnalytics.new.offers_histogram
    fee = histogram.inject({}) do |hash, o|
      hash.update o['key_as_string'] => o['fee']['value']
    end
    render json: fee
  end

  def revenue_by_date
    authorize! :read, :finance
    revenue_histogram = Admin::RevenueAnalytics.new(params).histogram
    revenue = revenue_histogram.inject({}) do |hash, o|
      hash.update o['key_as_string'] => o['amount']['value'].round(2)
    end
    render json: revenue
  end

  def orders_by_date
    authorize! :read, :finance
    histogram = Admin::OrdersDashboardAnalytics.new.orders_histogram
    paid_amount = histogram.inject({}) do |hash, o|
      hash.update o['key_as_string'] => o['paid_amount']['value'].round(2)
    end
    render json: paid_amount
  end

  private

  def authorize_user
    authorize! :read, :admin_dashboard
  end
end
