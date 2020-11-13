# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test '#my_boxes - for user with subscription' do
    sign_in users(:customer)
    get my_boxes_users_path

    assert_redirected_to subscription_period_path(subscription_periods(:customer_1_subscription_2_period))
  end

  test '#my_boxes - for user without subscription' do
    sign_in users(:new_customer)
    get my_boxes_users_path

    assert_response :success
  end

  test '#my_plan - for user with subscription' do
    sign_in users(:customer)
    get my_plan_users_path

    assert_redirected_to subscription_path(subscriptions(:customer_subscription_1))
  end

  test '#my_plan - for user without subscription' do
    sign_in users(:new_customer)
    get my_plan_users_path

    assert_response :success
  end

  test '#my_payment - for user with subscription' do
    sign_in users(:customer)
    get my_payment_users_path

    assert_redirected_to subscription_payment_path(subscriptions(:customer_subscription_1), id: 0)
  end

  test '#my_payment - for user without subscription' do
    sign_in users(:new_customer)
    get my_payment_users_path

    assert_response :success
  end
end
