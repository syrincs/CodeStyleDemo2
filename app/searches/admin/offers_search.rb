class Admin::OffersSearch
  FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF'].to_set
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def search
    scope = Offer.includes(:user, product: :photos)
    if params.key?(:q) && params[:q].present?
      query = ["users.slug LIKE :q OR users.first_name LIKE :q OR users.last_name LIKE :q OR products.title LIKE :q OR products.description LIKE :q", q: "%#{params[:q]}%"]
      scope.where(query)
    end
    scope = scope.paid if params.key?(:paid) && true?(params[:paid])
    scope = scope.accepted if params.key?(:accepted) && true?(params[:accepted])

    scope.ordered.page(params[:page])
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
