# frozen_string_literal: true

require 'test_helper'

class SubscriptionPeriodsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users :customer
    @subscription_period = subscription_periods :customer_1_subscription_1_period
    sign_in @user
  end

  test '#show' do
    get subscription_period_path(@subscription_period)

    assert_response :success
  end

  test '#show - not allowed to see subscription periods of different people' do
    get subscription_period_path(subscription_periods(:customer_2_subscription_2_period))

    assert_redirected_to root_url
  end
end
