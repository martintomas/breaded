# frozen_string_literal: true

class UsersController < ApplicationController
  def my_boxes
    @subscription_period = SubscriptionPeriod.joins(:subscription).where(subscriptions: { user: current_user }).order(:created_at).last
    return redirect_to foods_path if @subscription_period.blank?
    render 'subscription_periods/show'
  end

  def show; end
end
