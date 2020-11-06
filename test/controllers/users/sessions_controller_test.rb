# frozen_string_literal: true

require 'test_helper'

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users :customer
  end

  test '#new' do
    get new_user_session_path
    assert_response :success
  end

  test '#sign_in as customer without active subscriptions' do
    @user.subscriptions.update_all active: false
    post user_session_path, params: { user: { email: @user.email, password: 'customer' }}

    assert_redirected_to foods_path
  end

  test '#sign_in as customer with active subscription' do
    post user_session_path, params: { user: { email: @user.email, password: 'customer' }}

    assert_redirected_to my_boxes_users_path
  end

  test '#sign_in as admin' do
    post user_session_path, params: { user: { email: users(:admin).email, password: 'password' }}
    assert_redirected_to admin_dashboard_url
  end
end
