# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :store_user_location!
  before_action :authenticate_user!

  def new
    @subscription_former = Subscriptions::NewSubscriptionFormer.new shopping_basket_variant: params[:shopping_basket_variant],
                                                                    user: current_user
  end

  def create
    @subscription_former = Subscriptions::NewSubscriptionFormer.new subscription_former_params.merge(user: current_user)
                                                                      .merge(subscription_params)

    if @subscription_former.save
      redirect_to foods_path
    else
      render :new
    end
  end

  private

  def subscription_former_params
    params.require(:subscriptions_new_subscription_former).permit(:subscription_plan_id, :delivery_date_from,
                                                                  :delivery_date_to, :address_line, :street, :city,
                                                                  :postal_code, :shopping_basket_variant)
  end

  def subscription_params
    params.permit(:stripe_token, :basket_items)
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end
