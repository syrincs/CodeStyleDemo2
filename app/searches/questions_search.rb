class QuestionsSearch
  FALSE_VALUES = [false, 0, '0', 'f', 'F', 'false', 'FALSE', 'off', 'OFF'].to_set

  def initialize(params)
    @params = params
  end

  def search
    scope = Question.order(created_at: :desc).includes(:product, :answer)
    scope = scope.by_user(@params[:user_id]) if @params.include? :user_id

    if @params.include? :answered
      scope = true?(@params[:answered]) ? scope.answered : scope.not_answered
    end

    scope.page(@params[:page])
  end

  private

  def false?(value)
    FALSE_VALUES.include?(value)
  end

  def true?(value)
    !false?(value)
  end
end