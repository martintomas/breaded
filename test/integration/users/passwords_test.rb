# frozen_string_literal: true

require 'test_helper'

class Users::PasswordsTest < ActionDispatch::IntegrationTest
  test '#new' do
    get new_user_password_path

    assert_select 'form.login-form' do
      assert_select 'fieldset#login-fieldset' do
        assert_select "label[for=user_email]"
        assert_select 'input#user_email'
      end
      assert_select "input#login-form-submit[type='submit'][value=?]", I18n.t('app.forgotten_password.form_submit')
    end
  end
end
