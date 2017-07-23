class Admin::MessagesController < Admin::BaseController
  skip_before_filter :require_login, :authorize_user, only: [:reply]

  def reply
    Rollbar.log "SMS from Twillo: #{params.inspect}".inspect
    user = User.find_by(phone_number: [params[:From], params[:From].to_s.gsub('+1', '')])
    if user
      AdminMessage.new type: 'sms', body: params[:Body], user: user
    end
    render :reply, format: :xml
  end

  def index
    @messages = AdminMessage.ordered.includes(:sender, :recipient).page(params[:page])
  end

  def new
    @message = AdminMessage.new(new_message_params)
  end

  def create
    manager = AdminMessagesManager.new(current_user)
    @message = manager.sent params
    redirect_to admin_orders_path, notice: 'Message has been sent sucessfully'
  rescue AdminMessagesManager::Error
    @message = manager.message
    render :new
  end

  private

  def authorize_user
    authorize! :read, :admin_dashboard
  end

  def new_message_params
    params.permit(:type, :recipient_id, :body, :subject)
  end

  def message_params
    params.require(:admin_message).permit(:body, :type, :recipient_id, :subject)
  end
end
