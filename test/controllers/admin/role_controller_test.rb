# frozen_string_literal: true

require 'test_helper'

class Admin::RoleControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @role = roles :admin
  end

  test '#index' do
    get admin_roles_url

    assert_response :success
  end

  test '#show' do
    get admin_role_url(@role)

    assert_response :success
  end

  test '#new' do
    assert_difference 'Role.count', 1 do
      post admin_roles_url, params: { role: { name: 'NEW ROLE' } }

      assert_redirected_to admin_role_url(Role.last)
    end
  end

  test '#update' do
    patch admin_role_url(@role), params: { role: { name: 'UPDATED ROLE' } }

    assert_equal @role.reload.name, 'UPDATED ROLE'
    assert_redirected_to admin_role_url(@role)
  end

  test '#destroy' do
    assert_difference 'Role.count', -1 do
      delete admin_role_url(@role)

      assert_redirected_to admin_roles_url
    end
  end
end
