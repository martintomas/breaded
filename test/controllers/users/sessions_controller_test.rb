# frozen_string_literal: true

require 'test_helper'

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
  test '#new' do
    get new_user_session_path
    assert_response :success
  end

  test '#sign_in as customer' do
    post user_session_path, params: { user: { email: users(:customer).email,
                                                 password: 'customer' }}
    assert_redirected_to root_path
  end

  test '#sign_in as admin' do
    post user_session_path, params: { user: { email: users(:admin).email,
                                                 password: 'password' }}
    assert_redirected_to admin_dashboard_url
  end
end
