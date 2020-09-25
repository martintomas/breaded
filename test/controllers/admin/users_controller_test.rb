# frozen_string_literal: true

require 'test_helper'

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @user = users :admin
  end

  test '#index' do
    get admin_users_url

    assert_response :success
  end

  test '#show' do
    get admin_user_url(@user)

    assert_response :success
  end

  test '#new' do
    assert_difference 'User.count', 1 do
      post admin_users_url, params: { user: { first_name: 'First Name',
                                              last_name: 'Last Name',
                                              email: 'test@test.test',
                                              password: '111111' } }
      user = User.last
      assert_equal user.first_name, 'First Name'
      assert_equal user.last_name, 'Last Name'
      assert_equal user.email, 'test@test.test'
      assert_redirected_to admin_user_url(user)
    end
  end

  test '#update' do
    patch admin_user_url(@user), params: { user: { first_name: 'First Name' } }

    assert_equal @user.reload.first_name, 'First Name'
    assert_redirected_to admin_user_url(@user)
  end

  test '#destroy' do
    assert_difference 'User.count', -1 do
      delete admin_user_url(@user)

      assert_redirected_to admin_users_url
    end
  end
end
