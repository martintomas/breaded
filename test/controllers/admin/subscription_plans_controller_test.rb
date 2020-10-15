# frozen_string_literal: true

require 'test_helper'

class Admin::SubscriptionPlansControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @subscription_plan = subscription_plans :four_times_every_month
  end

  test '#index' do
    get admin_subscription_plans_url

    assert_response :success
  end

  test '#show' do
    get admin_subscription_plan_url(@subscription_plan)

    assert_response :success
  end

  test '#new' do
    get new_admin_subscription_plan_url

    assert_response :success
  end

  test '#create' do
    assert_difference 'SubscriptionPlan.count', 1 do
      post admin_subscription_plans_url, params: { subscription_plan: { currency_id: currencies(:EUR).id,
                                                                        price: 10.25,
                                                                        number_of_deliveries: 5 } }
      subscription_plan = SubscriptionPlan.last
      assert_equal currencies(:EUR), subscription_plan.currency
      assert_equal 10.25.to_d, subscription_plan.price
      assert_equal 5, subscription_plan.number_of_deliveries
      assert_redirected_to admin_subscription_plan_url(subscription_plan)
    end
  end

  test '#update' do
    patch admin_subscription_plan_url(@subscription_plan), params: { subscription_plan: { price: 10.25 } }

    @subscription_plan.reload
    assert_equal 10.25.to_d, @subscription_plan.price
    assert_redirected_to admin_subscription_plan_url(@subscription_plan)
  end

  test '#destroy' do
    assert_difference 'SubscriptionPlan.count', -1 do
      delete admin_subscription_plan_url(@subscription_plan)

      assert_redirected_to admin_subscription_plans_url
    end
  end
end
