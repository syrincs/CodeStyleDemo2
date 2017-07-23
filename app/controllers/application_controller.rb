class ApplicationController < ActionController::Base
  include Concerns::SEO, Concerns::DataLayer

  protect_from_forgery
  helper_method :fee_percent

  def fee_percent
    5
  end

  private

  def not_authenticated
    redirect_to login_path, alert: 'You need to login first'
  end
end
