# frozen_string_literal: true

require 'test_helper'

class Subscriptions::PaymentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users :customer
    @subscription = @user.subscriptions.first
    sign_in @user
  end

  test '#new' do
    get new_subscription_payment_path(@subscription), params: { shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE }

    assert_response :success
  end

  test '#new - redirect user to profile page when subscription is already paid' do
    @subscription.update! stripe_subscription: 'test', active: true
    get new_subscription_payment_path(@subscription), params: { shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE }

    assert_redirected_to @subscription.user
  end
end
