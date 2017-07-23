class Admin::OrdersDashboardAnalytics
  def orders_histogram
    return [] unless orders_histogram_aggregation.present?
    @_orders_histogram ||= orders_histogram_aggregation['histogram']['buckets']
  end

  def offers_histogram
    return [] unless offers_histogram_aggregation.present?
    @_offers_histogram ||= offers_histogram_aggregation['histogram']['buckets']
  end

  def offers_fee
    return unless offers_aggregation.present?
    @_offers_fee ||= %w(today yesterday week last_week month last_month).inject({}) do |hash, period|
      hash.update period.to_sym => offers_aggregation['dates']['buckets'][period]['fee']['value']
    end
  end

  def statuses
    return [] unless statuses_aggregation.present?
    @_statuses ||= statuses_aggregation['statuses']['buckets']
  end

  def prices
    return {'percentiles' => [], 'histogram' => []} unless prices_aggregation.present?
    @_prices ||= {
      'percentiles' => prices_aggregation['prices_percentiles']['values'],
      'histogram' => prices_aggregation['prices_histogram']['buckets']
    }
  end

  def orders_income_by_purchesed
    return unless orders_income_by_purchesed_aggregation.present?
    @_orders_income_by_purchesed ||= %w(today yesterday week last_week month last_month).inject({}) do |hash, period|
      hash.update period.to_sym => orders_income_by_purchesed_aggregation['dates']['buckets'][period]['paid_amount']['value']
    end
  end

  private

  def orders_income_by_purchesed_aggregation
    dates = {
      date_range: {
        keyed: true,
        field: :purchesed_at,
        format: 'date',
        ranges: [
          {key: :today, from: 'now/d', to: 'now+1d/d'},
          {key: :yesterday, from: 'now-1d/d', to: 'now/d'},
          {key: :week, from: 'now/w', to: 'now+1w/w'},
          {key: :last_week, from: 'now-1w/w', to: 'now/w'},
          {key: :month, from: 'now/M', to: 'now+1M/M'},
          {key: :last_month, from: 'now-1M/M', to: 'now/M'}
        ]
      },
      aggs: {
        paid_amount: {
          sum: {
            field: :paid_amount
          }
        }
      }
    }
    @_orders_income_by_date_aggregation ||= OrdersIndex.aggregations(dates: dates).aggs
  end

  def offers_aggregation
    dates = {
      date_range: {
        keyed: true,
        field: :created_at,
        format: 'date',
        ranges: [
          {key: :today, from: 'now/d', to: 'now+1d/d'},
          {key: :yesterday, from: 'now-1d/d', to: 'now/d'},
          {key: :week, from: 'now/w', to: 'now+1w/w'},
          {key: :last_week, from: 'now-1w/w', to: 'now/w'},
          {key: :month, from: 'now/M', to: 'now+1M/M'},
          {key: :last_month, from: 'now-1M/M', to: 'now/M'}
        ]
      },
      aggs: {
        fee: {
          value_count: {
            field: :fee
          }
        }
      }
    }
    @_offers_aggregation ||= OffersIndex.aggregations(dates: dates).aggs
  end

  def offers_histogram_aggregation
    sum = {sum: {field: :fee}}
    number = {value_count: {field: :fee}}

    histogram = {
      date_histogram: {
        field: 'created_at',
        interval: '1d',
        min_doc_count: 0,
        extended_bounds: {
          min: Date.current.beginning_of_month.to_time.to_i * 1000,
          max: Date.current.end_of_month.to_time.to_i * 1000
        }
      },
      aggs: {fee: sum, number: number}
    }

    @_offers_histogram_aggregation ||= OffersIndex.aggregations(histogram: histogram).aggs
  end

  def orders_histogram_aggregation
    sum = {sum: {field: :paid_amount}}
    number = {value_count: {field: :paid_amount}}

    histogram = {
      date_histogram: {
        field: 'purchesed_at',
        interval: '1d',
        min_doc_count: 0,
        extended_bounds: {
          min: Date.current.beginning_of_month.to_time.to_i * 1000,
          max: Date.current.end_of_month.to_time.to_i * 1000
        }
      },
      aggs: {paid_amount: sum, number: number}
    }

    @_orders_histogram_aggregation ||= OrdersIndex.aggregations(histogram: histogram).aggs
  end

  def statuses_aggregation
    agg = {
      terms: {field: 'status'},
      aggs: {total: {stats: {field: 'price'}}}
    }
    @_statuses_aggregation ||= OrdersIndex.aggregations(statuses: agg).aggregations
  end

  def prices_aggregation
    percentiles = {
      percentiles: {
        field: 'price',
        percents: [25, 50, 75, 95, 100]
      }
    }
    histogram = {
      histogram: {
        field: 'price',
        interval: 10,
        order: { _count: 'desc' }
      }
    }
    @_prices_aggregation ||= OrdersIndex.aggregations(prices_percentiles: percentiles, prices_histogram: histogram).aggregations
  end
end
