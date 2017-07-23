class Admin::ProductsSearch
  FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF'].to_set
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def search
    if no_filters?
      scope = Product.on_sale
    else
      scope = Product.all
    end

    if params.key?(:hidden) && true?(params[:hidden])
      scope = scope.hidden
    else
      scope = scope.not_hidden
    end
    scope = scope.sold if params.key?(:sold) && true?(params[:sold])
    scope = scope.for_sale if params.key?(:sold) && false?(params[:sold])
    scope = scope.with_offers if params.key?(:offers) && true?(params[:offers])
    scope = scope.without_offers if params.key?(:offers) && false?(params[:offers])
    scope.order(created_at: :desc).page(params[:page])
  end

  private

  def no_filters?
    !(params.key?(:sold) || params.key?(:hidden) || params.key?(:offers))
  end

  def false?(value)
    FALSE_VALUES.include?(value)
  end

  def true?(value)
    !false?(value)
  end
end
