# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  prepend_before_action :authenticate_user!, :store_user_location!

  def new
    subscription = Subscription.find_by_id params[:subscription_id]
    @subscription_former = Subscriptions::NewSubscriptionFormer.new subscription: subscription,
                                                                    shopping_basket_variant: params[:shopping_basket_variant],
                                                                    user: current_user
  end

  def create
    @subscription_former = Subscriptions::NewSubscriptionFormer.new subscription_former_params.merge(user: current_user)
                                                                      .merge(subscription_params)
    if @subscription_former.save
      redirect_to new_subscription_payment_path(@subscription_former.subscription,
                                                shopping_basket_variant: @subscription_former.shopping_basket_variant)
    else
      render :new
    end
  end

  private

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
