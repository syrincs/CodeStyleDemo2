class Admin::QuestionsController < Admin::BaseController
  before_action :load_resource, except: [:index]

  def index
    @questions = QuestionsSearch.new(params).search
  end

  def edit
  end

  def update
    if @question.update(question_params)
      redirect_to admin_questions_path, notice: 'Successfully updated'
    else
      redirect_to :back, alert: errors_for(@question.errors)
    end
  end

  def destroy
    @question.destroy
    redirect_to :back, notice: 'Successfully removed.'
  end

  private

  def authorize_user
    authorize! :manage, User
  end

  def load_resource
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :description)
  end

  def errors_for(errors)
    errors = errors.messages.flat_map do |key, value|
      value
    end.join(', ')
  end
end