# frozen_string_literal: true

require 'test_helper'

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'user gets redirected when not logged in' do
    get admin_dashboard_url

    assert_redirected_to new_user_session_url
  end

  test 'user gets redirected when do not have correct rights' do
    sign_in users(:customer)
    get admin_dashboard_url

    assert_redirected_to root_url
  end

  test 'admin is allowed to see' do
    sign_in users(:admin)
    get admin_dashboard_url
    assert_response :success
  end
end
