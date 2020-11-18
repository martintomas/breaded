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

  test '#edit' do
    sign_in users(:customer)
    get edit_user_path(users(:customer))

    assert_response :success
  end

  test '#edit - can edit only your profile' do
    sign_in users(:customer)
    get edit_user_path(users(:new_customer))

    assert_redirected_to root_url
  end

  test '#update' do
    user = users(:customer)
    sign_in user
    patch user_path(user), params: { user: { first_name: 'Updated First Name',
                                             last_name: 'Updated Last Name',
                                             secondary_phone_number: '+420123456789',
                                             email: 'test@test.test',
                                             password: '12345679' } }
    assert_redirected_to edit_user_path(user)

    user.reload
    assert_equal 'Updated First Name', user.first_name
    assert_equal 'Updated Last Name', user.last_name
    assert_equal '+420123456789', user.secondary_phone_number
    assert_equal 'test@test.test', user.email
  end

  test '#update - password is empty' do
    user = users(:customer)
    sign_in user
    patch user_path(user), params: { user: { first_name: 'Updated First Name',
                                             last_name: 'Updated Last Name',
                                             secondary_phone_number: '+420123456789' } }
    assert_redirected_to edit_user_path(user)

    user.reload
    assert_equal 'Updated First Name', user.first_name
    assert_equal 'Updated Last Name', user.last_name
    assert_equal '+420123456789', user.secondary_phone_number
  end

  test '#update - can update only your user' do
    sign_in users(:customer)
    patch user_path(users(:new_customer)), params: { user: { first_name: 'Updated First Name' } }

    assert_redirected_to root_url
  end
end
