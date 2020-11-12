# frozen_string_literal: true

class Subscriptions::PaymentsController < ApplicationController
  before_action :set_subscription

  def new
    authorize! :read, @subscription
    redirect_to my_boxes_users_path if @subscription.active?
  end

  def show
    authorize! :read, @subscription
  end

  def edit
    authorize! :update, @subscription
  end

  private

  def set_subscription
    @subscription = Subscription.find params[:subscription_id]
  end
end
