# frozen_string_literal: true

require 'test_helper'

class Users::SessionsTest < ActionDispatch::IntegrationTest
  test '#new' do
    get new_user_session_path

    assert_select 'form.login-form' do
      assert_select 'h1#title-login', I18n.t('app.login.label')
      assert_select 'div.panel-switch' do
        assert_select 'button#log_in', I18n.t('app.login.login_button')
        assert_select 'button.active-button#sign_up', I18n.t('app.login.signup_button')
      end
      assert_select 'fieldset#login-fieldset' do
        assert_select "label[for=user_email]"
        assert_select 'input#user_email'
        assert_select "label[for=user_password]"
        assert_select 'input#user_password'
      end
      assert_select 'p', I18n.t('app.login.forgot_password_link')
      assert_select "input#login-form-submit[type='submit'][value=?]", I18n.t('app.login.login_submit')
    end
  end
end
