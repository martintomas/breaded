# frozen_string_literal: true

require 'test_helper'

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test '#new' do
    get new_user_registration_path
    assert_response :success
  end

  test '#create' do
    assert_difference 'User.count', 1 do
      assert_emails 1 do
        post user_registration_path, params: { user: { first_name: 'First Name',
                                                       last_name: 'Last Name',
                                                       email: 'test@test.test',
                                                       password: 'password' }}
        user = User.last
        assert_equal 'First Name', user.first_name
        assert_equal 'Last Name', user.last_name
        assert_equal 'test@test.test', user.email
        assert_redirected_to root_path
      end
    end
  end
end
