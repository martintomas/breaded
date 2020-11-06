# frozen_string_literal: true

class SubscriptionPeriodsController < ApplicationController
  before_action :set_subscription_period, only: %i[show]

  def show
    authorize! :read, @subscription_period
  end

  private

  def set_subscription_period
    @subscription_period = SubscriptionPeriod.find params[:id]
  end
end
