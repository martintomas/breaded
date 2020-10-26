# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :store_user_location!
  before_action :authenticate_user!
  before_action :set_subscription, only: :checkout

  def new
    @subscription_former = Subscriptions::NewSubscriptionFormer.new shopping_basket_variant: params[:shopping_basket_variant],
                                                                    user: current_user
  end

  def create
    @subscription_former = Subscriptions::NewSubscriptionFormer.new subscription_former_params.merge(user: current_user)
                                                                      .merge(subscription_params)
    if @subscription_former.save
      redirect_to checkout_subscription_path(@subscription_former.subscription)
    else
      render :new
    end
  end

  def checkout
    return head :forbidden unless @subscription.user == current_user
    redirect_to user_url(@subscription.user, stripe_state: :success) if @subscription.stripe_subscription.present?
  end

  private

  def set_subscription
    @subscription = Subscription.find params[:id]
  end

  def subscription_former_params
    params.require(:subscriptions_new_subscription_former).permit(:subscription_plan_id, :delivery_date_from,
                                                                  :address_line, :street, :city, :postal_code, :phone_number,
                                                                  :shopping_basket_variant)
  end

  def subscription_params
    params.permit(:basket_items)
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end
