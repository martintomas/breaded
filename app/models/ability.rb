# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user
    @roles = user.blank? ? [] : user.roles.pluck(:name).map(&:to_sym)

    default_rights
    customer_rights if @roles.include? :customer
    admin_rights if @roles.include? :admin
  end

  private

  def admin_rights
    can :manage, :all
  end

  def customer_rights
    can %i[read index create update], Order, user_id: @user.id
    can %i[read index create update], SubscriptionPeriod, subscription: { user_id: @user.id }
    can %i[read index create update], Subscription, user_id: @user.id
    can %i[read update], User, id: @user.id
    can %i[read index create update destroy], Address do |address|
      (address.addressable_type == 'User' && address.addressable_id == @user.id) ||
        (address.addressable_type == 'Order' && address.addressable_id.in?(@user.order_ids))
    end
  end

  def default_rights
    can %i[read index], Food, enabled: true
    can %i[read index], Producer, enabled: true
    can %i[create], ProducerApplication
    can %i[create], User
    can %i[read index], SubscriptionPlan
  end
end
