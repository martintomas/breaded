# frozen_string_literal: true

class Subscriptions::PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscription

  def new; end

  private

  def set_subscription
    @subscription = Subscription.find params[:subscription_id]
  end
end
