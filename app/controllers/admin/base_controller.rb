class Admin::BaseController < ApplicationController
  layout 'admin'
  before_filter :require_login
  before_filter :authorize_user
end
