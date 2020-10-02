# frozen_string_literal: true

require 'test_helper'

class Users::RegistrationsTest < ActionDispatch::IntegrationTest
  test '#new' do
    get new_user_registration_path

    assert_select 'form.login-form' do
      assert_select 'h1#title-login', I18n.t('app.login.label')
      assert_select 'div.panel-switch' do
        assert_select 'button.active-button#log_in', I18n.t('app.login.login_button')
        assert_select 'button#sign_up', I18n.t('app.login.signup_button')
      end
      assert_select 'fieldset#signup-fieldset' do
        assert_select "label[for=user_first_name]"
        assert_select 'input#user_first_name'
        assert_select "label[for=user_last_name]"
        assert_select 'input#user_last_name'
        assert_select "label[for=user_email]"
        assert_select 'input#user_email'
        assert_select "label[for=user_password]"
        assert_select 'input#user_password'
      end
      assert_select "input#signup-form-submit[type='submit'][value=?]", I18n.t('app.registration.registration_submit')
    end
  end
end
