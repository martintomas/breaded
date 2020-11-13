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

    assert_redirected_to my_boxes_users_path
  end

  test '#new - not allowed to pay subscription of somebody else' do
    get new_subscription_payment_path(subscriptions(:customer_subscription_2))

    assert_redirected_to root_url
  end

  test '#show' do
    get subscription_payment_path(@subscription, id: 0)

    assert_response :success
  end

  test '#show - not allowed to see payment method of somebody else' do
    get subscription_payment_path(subscriptions(:customer_subscription_2), id: 0)

    assert_redirected_to root_url
  end

  test '#edit' do
    Stripe::SetupIntent.stub :create, OpenStruct.new(client_secret: 'client_secret'), [customer: ''] do
      get edit_subscription_payment_path(@subscription, id: 0)

      assert_response :success
    end
  end

  test '#edit - not allowed to edit payment method of somebody else' do
    get edit_subscription_payment_path(subscriptions(:customer_subscription_2), id: 0)

    assert_redirected_to root_url
  end
end
