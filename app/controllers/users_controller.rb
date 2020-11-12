# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[edit]
  before_action :set_subscription_period

  def my_boxes
    redirect_to subscription_period_path(@subscription_period) if @subscription_period.present?
  end

  def my_plan
    redirect_to subscription_path(@subscription_period.subscription) if @subscription_period.present?
  end
  
  def my_payment
    redirect_to subscription_payment_path(@subscription_period.subscription, id: 0) if @subscription_period.present?
  end

  def edit
    authorize! :update, @user
  end

  private

  def set_user
    @user = User.find params[:id]
  end

  def set_subscription_period
    @subscription_period ||= begin
      SubscriptionPeriod.joins(:subscription).where(subscriptions: { active: true, user: current_user }).order(:created_at).last
    end
  end
end
