# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test '#my_boxes - for user with subscription' do
    sign_in users(:customer)
    get my_boxes_users_path

    assert_response :success
  end

  test '#my_boxes - for user without subscription' do
    sign_in users(:new_customer)
    get my_boxes_users_path

    assert_redirected_to foods_path
  end
end
