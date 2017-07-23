class Dashboard::QuestionsController < ApplicationController
  before_filter :require_login
  before_action :load_resource, except: [:index]

  def index
    @questions = QuestionsSearch.new(questions_params).search
  end

  def destroy
    @question.destroy
    redirect_to :back, notice: 'Successfully removed.'
  end

  private

  def questions_params
    params.merge(user_id: current_user.id)
  end

  def load_resource
    @question = Question.find(params[:id])
  end
end
