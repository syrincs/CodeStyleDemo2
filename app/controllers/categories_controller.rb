class CategoriesController < ApplicationController
  def index
    if params[:parent]
      render json: parent.children
    else
      render json: {}
    end
  end

  private

  def parent
    if params[:parent].to_i > 0
      Category.find_by(id: params[:parent])
    else
      Category.find_by(code: params[:parent])
    end
  end
end
