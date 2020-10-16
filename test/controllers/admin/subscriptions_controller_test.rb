# frozen_string_literal: true

require 'test_helper'

class Admin::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @subscription = subscriptions :not_active_subscription
  end

  test '#index' do
    get admin_subscriptions_url

    assert_response :success
  end

  test '#show' do
    get admin_subscription_url(@subscription)

    assert_response :success
  end

  test '#update' do
    patch admin_subscription_url(@subscription), params: { subscription: { user_id: users(:customer).id,
                                                                           subscription_plan_id: subscription_plans(:four_times_every_month).id,
                                                                           active: true,
                                                                           number_of_orders_left: 4,
                                                                           number_of_items: 10 } }

    @subscription.reload
    assert_equal @subscription.user, users(:customer)
    assert_equal @subscription.subscription_plan, subscription_plans(:four_times_every_month)
    assert @subscription.active
    assert_equal @subscription.number_of_orders_left, 4
    assert_equal @subscription.number_of_items, 10
    assert_redirected_to admin_subscription_url(@subscription)
  end
end
