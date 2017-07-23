class QuestionsController < ApplicationController
  before_action :question_params

  def create
    @question = current_user.questions.build(question_params)
    if @question.valid?
      if verify_recaptcha(model: @question)
        @question.save
        QuestionMailer.created(@question.id).deliver_now
        redirect_to :back, notice: 'Question is added successfully'
      else
        redirect_to :back
      end
    else
      redirect_to :back, alert: errors_for(@question.errors)
    end
  end

  private

  def question_params
    params.require(:question).permit(:product_id, :title, :description)
  end

  def errors_for(errors)
    errors = errors.messages.flat_map do |key, value|
      value
    end.join(', ')
  end
end
