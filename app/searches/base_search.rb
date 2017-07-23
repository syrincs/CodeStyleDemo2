class BaseSearch
  class_attribute :index

  class_attribute :per_page
  self.per_page = 20

  def initialize(params={}, &block)
    @index = self.index.constantize
    @params = params.dup
    @q = params[:q].presence
    yield self if block_given?
  end

  def search(&block)
    rescue_search do
      @query ||= if block_given?
        paginate yield(query)
      else
        paginate query
      end
    end
#    return @query
    #binding.pry
  end

  def all
    rescue_search do
      @query ||= query.offset(0).limit(10000)
    end
  end

  def query
    raise NotImplementedError
  end

  def result_from
    offset + 1
  end

  def result_to
    offset + @query.count
  end

  def offset
    (page - 1) * per_page
  end

  def page
    (@params[:page].presence || 1).to_i
  end

  def total_count
    @query.total_count
  end

  private

  def paginate(query)
    query.offset(offset).limit(per_page)
  end

  def q
    return {} unless @q.present?
    {
      query_string: {
        fields: searchable_attributes,
        query: @q,
        analyzer: 'stopwords',
        default_operator: 'and'}
    }
  end

  def searchable_attributes
    raise NotImplementedError
  end

  def by_term(name, value=@params[name])
    return {} unless value.present?
    {
      term: {
        name => value
      }
    }
  end

  def by_boolean(name, value=@params[name])
    {
      term: {
        name => !!value
      }
    }
  end

  def by_terms(name, value=@params[name])
    return {} unless value.present?
    {
      terms: {
        name => value,
        execution: 'bool'
      }
    }
  end

  def by_range(name, to: @params[:"#{name}_to"], from: @params[:"#{name}_from"])
    range = {}
    return range unless to.present? || from.present?

    range[:gte] = from.to_f if from.present?
    range[:lte] = to.to_f if to.present?
    {
      range: {
        name => range
      }
    }
  end

  def by_range_dates(name, to: @params[:"#{name}_from"], from: @params[:"#{name}_to"])
    range = {}
    return range unless to.present? || from.present?

    range[:gte] = from if from.present?
    range[:lte] = to if to.present?
    {
      range: {
        name => range
      }
    }
  end

  def rescue_search &block
    block.call.tap { |scope| scope.to_a }
  rescue Elasticsearch::Transport::Transport::Errors::BadRequest => e
    @error = e.message.match(/QueryParsingException\[([^;]+)\]/).try(:[], 1)
    Rollbar.log(e)
    @index.none
  end
end


