class OauthsController < ApplicationController
  skip_before_filter :require_login

  def oauth
    login_at(params[:provider])
  end

  def callback
    provider = provider_params[:provider]
    if @user = login_from(provider)
      push_event
      redirect_to root_path
    else
      begin
        @user = try_to_find_user_by_email || create_from(provider)

        reset_session
        auto_login(@user)
        push_event_signed_up
        push_event
        redirect_to root_path
      rescue => e
        Rollbar.log(e)
        redirect_to root_path, alert: "Failed to login from #{provider.titleize}!"
      end
    end
  end

  private

  def try_to_find_user_by_email
    if user = find_user_by_email
      user.add_provider_to_user(provider_params[:provider].to_s, @user_hash[:uid].to_s)
      user
    end
  end

  def find_user_by_email
    return unless @user_hash
    if email = @user_hash.fetch(:user_info, {}).fetch('email')
      User.find_by(email: email)
    end
  end

  def provider_params
    params.permit(:code, :provider)
  end

  def push_event
    push_to_data_layer_later event: 'VirtualPageview',
                             virtualPageURL: '/facebook_connected',
                             virtualPageTitle: 'virturl: Facebook connected'
  end

  def push_event_signed_up
    push_to_data_layer_later event: 'VirtualPageview',
                             virtualPageURL: '/signed_up',
                             virtualPageTitle: 'virturl: Signed up'
  end

  def create_from
    super.tap do |u|
      u.activate!
    end
  end
end
