# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    @roles = user.roles.pluck(:name).map(&:to_sym)

    customer_rights if @roles.include? :customer
    admin_rights if @roles.include? :admin
  end

  private

  def admin_rights
    can :manage, :all
  end

  def customer_rights

  end
end
