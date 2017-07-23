class Admin::RevenueAnalytics
  def initialize(params={})
    set_granularity_and_period(params.fetch(:scope, 'month'))
  end

  def periods
    dashboard_analytics = Admin::OrdersDashboardAnalytics.new
    bids = dashboard_analytics.offers_fee[:month] / 2
    sells = dashboard_analytics.orders_income_by_purchesed[:month] * 0.05

    dashboard_analytics.offers_fee.inject({}) do |hash, (period, value)|
      bids = value / 2
      sells = dashboard_analytics.orders_income_by_purchesed[period] * 0.05
      hash.update period => bids + sells
    end
  end

  def histogram
    orders_revenue_histogram = orders_revenue_histogram_aggregation['histogram']['buckets']
    offers_revenue_histogram = offers_revenue_histogram_aggregation['histogram']['buckets']
    @_revenue_histogram ||= orders_revenue_histogram.zip(offers_revenue_histogram).map do |(order, offer)|
      value = order['paid_amount']['value'] + offer['fee']['value']
      order.slice('key_as_string', 'key').merge 'amount' => {'value' => value}
    end
  end

  private

  def offers_revenue_histogram_aggregation
    sum = {sum: {script: %q(doc['fee'].value / 2)}}
    number = {value_count: {field: :fee}}
    histogram = histogram_by(:created_at, fee: sum, number: number)
    filter = filter(:created_at)
    @_revenue_histogram_aggregation ||= OffersIndex.filter(filter).aggregations(histogram).aggs
  end

  def orders_revenue_histogram_aggregation
    sum = {sum: {script: %q(doc['paid_amount'].value * 0.05)}}
    number = {value_count: {field: :paid_amount}}
    histogram = histogram_by(:purchesed_at, paid_amount: sum, number: number)
    filter = filter(:purchesed_at)
    @_orders_histogram_aggregation ||= OrdersIndex.filter(filter).aggregations(histogram).aggs
  end

  def filter(date_field)
    {
      range: {
        date_field => {
          gte: @period.min,
          lte: @period.max
        }
      }
    }
  end

  def histogram_by(date_field, aggs)
    {
      histogram:
        {
          date_histogram: {
            format: 'yyyy-MM-dd',
            field: date_field,
            interval: @granularity,
            min_doc_count: 0,
            extended_bounds: {
              min: @period.min,
              max: @period.max
            }
          },
          aggs: aggs
        }
    }
  end

  def determine_granularity_by_scope(scope)
    case scope
    when 'week'
      '1d'
    when 'month'
      '1d'
    when 'all'
      determine_granularity_for_year
    else
      raise 'Unknown scope type. Available: "week", "month", "all"'
    end
  end

  def determine_granularity_for_year
    case
    when first_date > 2.years.ago
      '1M'
    when first_date > 1.years.ago
      '2w'
    when first_date > 6.months.ago
      '1w'
    else
      '1d'
    end
  end

  def determine_period_by_scope(scope)
    case scope
    when 'week'
      [Date.current.beginning_of_week.to_time.to_i * 1000,
       Date.current.end_of_week.to_time.to_i * 1000]
    when 'month'
      [Date.current.beginning_of_month.to_time.to_i * 1000,
       Date.current.end_of_month.to_time.to_i * 1000]
    when 'all'
      [first_date.to_i * 1000,
       Date.current.end_of_week.to_time.to_i * 1000]
    else
      raise 'Unknown scope type. Available: "week", "month", "all"'
    end
  end

  def first_date
    @_first_date ||= [Offer.order('created_at').first.created_at, Order.order('created_at').first.created_at].min
  end

  def set_granularity_and_period(scope)
    @period = determine_period_by_scope(scope)
    @granularity = determine_granularity_by_scope(scope)
  end
end
