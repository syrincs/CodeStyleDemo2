class ProductsSearch < BaseSearch
  self.index = 'ProductsIndex'

  def initialize(*args)
    super
    if @params[:category].present? && category = Category.find(@params[:category])
      @params[:category] = [category.code] + [category.children.map(&:code)]
    end
    @params[:car] ||= {}
  end

  def latest
    rescue_search do
      query.reorder(created_at: :desc)
    end
  end

  def sold_deals
    rescue_search do
      @index.filter(sold).order(:_score).load(scope: scope)
    end
  end

  def top_in_category(category)
    rescue_search do
      query.filter(by_category([category.code] + category.children.map(&:code))).random_score(Time.current.yday)
    end
  end

  def trending
    rescue_search do
      query.filter(range: {offers_count: { gt: 0 }}).reorder(price_difference: :desc, offers_count: :desc)
    end
  end

  def query
    @index.
      query(q).
      filter(not_hidden).
      filter(published).
      filter(not_sold).
      filter(active).
      filter(by_category).
      filter(by_manufacturer).
      filter(by_car_make).
      filter(by_car_model).
      filter(by_price).
      filter(by_condition).
      filter(by_vin).
      filter(by_year).
      filter(by_mileage).
      filter(by_drive_type).
      order(order_by).
      order(:_score).
      aggs(category_aggs).
      load(scope: scope)
  end

  def similar(product)
    @q = product.title
    query = @index.
      query({
              bool: {
                should: [
                  q,
                  by_term(:category_id, product.category.try(:id))
                ],
                must_not: by_term(:_id, product.id)
              }
            }).
      filter(not_hidden).
      filter(not_sold).
      filter(active).
      random_score(product.id).
      load(scope: scope)

    rescue_search do
      @query ||= query.limit(4)
    end
  end

  def scope
    Product.includes(:ships_from_address, :photos, :category)
  end

  def per_page
    case @params[:view]
    when 'big_grid', 'list'
      20
    else
      15
    end
  end

  def categories
    @_categories ||= begin
      all_products = search.aggs.fetch('all_products', {}).fetch('filtered', {})
      all_products.fetch('category', {}).fetch('buckets', []).inject(all_products: all_products['doc_count']) do |hash, bucket|
        hash.update bucket['key'].to_i => bucket['doc_count']
      end
    end
  end

  private

  def category_aggs
    {
      all_products: {
        global: {},
        aggs: {
          filtered: {
            filter: {and: [not_hidden, not_sold, active]},
            aggs: {category: {terms: {field: 'category_id', size: 0}}}
          }
        }
      }
    }
  end

  def not_hidden
    by_boolean(:hidden, false)
  end

  def published
    by_boolean(:published, true)
  end

  def not_sold
    by_boolean(:sold, false)
  end

  def sold
    by_boolean(:sold, true)
  end

  def active
    by_range_dates(:auction_finish_at, from: Time.now)
  end

  def by_year
    by_term(:year, @params[:car][:year])
  end

  def by_mileage
    by_range(:mileage, from: @params[:car][:mileage_from], to: @params[:car][:mileage_to])
  end

  def by_vin
    by_term(:vin, @params[:car][:vin])
  end

  def by_drive_type
    by_term(:drive_type, @params[:car][:drive_type])
  end

  def searchable_attributes
    [
      :title, :description, :manufacturer, :category_name,
      :user_name, :condition, :location, :car_make_name, :car_model_name,
      :drive_type, :engine, :trim
    ]
  end

  def by_manufacturer
    by_term(:manufacturer, @params[:manufacturer].try(:downcase))
  end

  def by_category(category=@params[:category])
    {
      terms: {
        category_code: Array.wrap(category)
      }
    } if category.present?
  end

  def by_car_make
    by_term(:car_make_id)
  end

  def by_car_model
    by_term(:car_model_id)
  end

  def by_price
    by_range(:price)
  end

  def by_condition
    by_terms(:condition)
  end

  def order_by
    return {} unless @params[:sort].present? && @params[:sort].in?(%w[price_low price_high])
    {
      price: @params[:sort] == 'price_low' ? :asc : :desc
    }
  end
end
