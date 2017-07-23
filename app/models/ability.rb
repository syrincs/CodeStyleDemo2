class Ability
  include CanCan::Ability

  attr_accessor :current_user, :params

  def initialize(current_user, params = {})
    self.current_user = current_user
    self.params = params

    if current_user
      authenticated_abilities
    else
      anonymous_abilities
    end
  end

  private

  def authenticated_abilities
    can :read, Product do |product|
      !product.hidden?
    end
    can :control, Product do |product|
      product.seller == current_user && !product.hidden?
    end
    can :edit, Product do |product|
      product.seller == current_user && !product.hidden? && product.offers.empty? && !product.sold?
    end
    can :delete, Product do |product|
      product.seller == current_user && !product.hidden? && product.offers.empty? && !product.sold?
    end
    can :answer, Question do |question|
      question.product.seller == current_user && !question.product.sold?
    end
    can :manage, WatchList do |watch_list|
      watch_list.user == current_user
    end
    staff_abilities if is_staff?
    role_specific_abilities
  end

  def anonymous_abilities
    can :read, Product do |product|
      !product.hidden?
    end
  end

  def role_specific_abilities
    case
    when current_user.has_role?(:admin)
      admin_abilities
    when current_user.has_role?(:manager)
      manager_abilities
    when current_user.has_role?(:editor)
      editor_abilities
    when current_user.has_role?(:images_editor)
      images_editor_abilities
    when current_user.has_role?(:sales)
      sales_abilities
    end
  end

  def staff_abilities
    can :read, :admin_dashboard
  end

  def admin_abilities
    cannot :login_as, User do |user|
      user.has_role? :admin
    end
    can :delete, Product
    can :mark_featured, Product
    can :read, :finance
    can :manage, :all
  end

  def manager_abilities
    can :manage, User
    cannot :edit, User do |user|
      user.id == current_user.id
    end
    cannot :login_as, User
    can :assign_role, :editor
  end

  def editor_abilities
    can :mark_featured, Product
    can :manage, Product
    can :delete, Product
  end

  def images_editor_abilities
    can :manage, Product
    cannot :update_description, Product
    cannot :answer, Question
  end

  def sales_abilities
    can :assign_role, :user
    can :manage, User
    cannot :edit, User do |user|
      user.id == current_user.id
    end
    can :assign_role, :editor
    cannot :login_as, User do |user|
      !user.has_role?(:user)
    end
  end

  def is_staff?
    Role::STAFF_ROLES.any? { |role| current_user.has_role? role }
  end
end
