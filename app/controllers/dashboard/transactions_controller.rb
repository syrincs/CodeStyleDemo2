class Dashboard::TransactionsController < ApplicationController
  before_filter :require_login

  helper_method :scope

  def index
    case scope
    when 'income'
      @payouts = incomes
    when 'charges'
      @charges = charges
    end
  end

  private

  def incomes
    current_user.payouts.where(destination: 'seller').includes(order: [:product]).order(created_at: :desc).page(params[:page])
  end

  def charges
    current_user.charges.includes(:offer, order: [:product]).order(created_at: :desc).page(params[:page])
  end

  def scope
    params[:scope].presence || 'charges'
  end
end
