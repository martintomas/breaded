# frozen_string_literal: true

require 'test_helper'

class Users::PasswordsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test '#new' do
    get new_user_password_path
    assert_response :success
  end

  test '#create' do
    assert_emails 1 do
      post user_password_path, params: { user: { email: users(:customer).email }}

      assert_redirected_to new_user_session_path
    end
  end
end
