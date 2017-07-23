class Dashboard::AnswersController < ApplicationController
  before_action :load_question

  def new
  end

  def create
    @answer = @question.build_answer(answer_params)
    if @answer.save
      AnswerMailer.created(@answer.id).deliver_now
      redirect_to dashboard_questions_path, notice: 'You have answered successfully!'
    else
      redirect_to :back, alert: 'Something went wrong, please check your answer!'
    end
  end

  def edit
  end

  def update
    if @question.answer.update(answer_params)
      redirect_to dashboard_questions_path, notice: 'Successfully updated'
    else
      redirect_to :back, alert: 'Something went wrong, please check your answer!'
    end
  end

  private

  def load_question
    @question = Question.find(params[:question_id])
  end

  def authorize_user
    authorize! :manage, Product
  end

  def answer_params
    params.require(:answer).permit(:question_id, :description)
  end
end
