class AnswersController < ApplicationController
  before_action :answer_params

  def create
    @answer = Answer.new(answer_params)
    authorize! :answer, @answer.question
    if @answer.save
      AnswerMailer.created(@answer.id).deliver_now
      redirect_to :back, notice: 'You have answered successfully!'
    else
      redirect_to :back, alert: 'Something went wrong, please check your answer!'
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:question_id, :description)
  end
end
