class Admin::UsersController < Admin::BaseController
  decorates_assigned :users
  decorates_assigned :user
  before_action :assign_user, only: [:edit, :update, :add_role, :remove_role, :login]

  def search
    query = ["email LIKE :q OR first_name LIKE :q OR last_name LIKE :q OR username LIKE :q", q: "%#{params[:q]}%"]
    @users = User.includes(roles: :resource).order(created_at: :desc).where(query).page(params[:page])
    render :index
  end

  def login
    session[:superuser_id] = current_user.id
    auto_login @user
    redirect_to root_url
  end

  def invite
    @invitation_form = Forms::InviteUser.new(User.new, invite_user_params)
    @user = if user = User.find_by(email: @invitation_form.email)
      UserLifecycleManager.new.resend_invite(user, @invitation_form)
    else
      UserLifecycleManager.new.invite(@invitation_form)
    end
    redirect_to({action: :index}, notice: "User #{@user.full_name} have been successfully invited.")
  rescue UserLifecycleManager::ValidationError => e
    @user = e.record
    render :new
  end

  def index
    @users = if params[:staff]
      User.staff.includes(roles: :resource).order(created_at: :desc).page(params[:page])
    else
      User.includes(roles: :resource).order(created_at: :desc).page(params[:page])
    end
  end

  def new
    @invitation_form = Forms::InviteUser.new(User.new)
  end

  def edit
  end

  def update
    @user.attributes = user_params
    if @user.save
      redirect_to action: :index
    else
      render :edit
    end
  end

  def add_role
    check_role!
    @user.add_role(params[:role])
    redirect_to action: :edit
  end

  def remove_role
    check_role!
    @user.remove_role(params[:role])
    redirect_to action: :edit
  end

  private

  def check_role!
    if !Role::ROLES.include?(params[:role].to_sym) || cannot?(:assign_role, params[:role].to_sym)
      raise ActiveRecord::RecordNotFound
    end
  end

  def assign_user
    @user = User.friendly.find(params[:id])
  end

  def authorize_user
    authorize! :manage, User
  end

  def user_params
    params.require(:user).permit(
      :email,
      :phone_number,
      :billing_token
    )
  end

  def invite_user_params
    params.require(:user).permit(
      :email,
      :first_name,
      :last_name,
      :assign_role,
      :invitation_message
    )
  end
end
