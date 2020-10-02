# frozen_string_literal: true

require "application_system_test_case"

class Users::PasswordsSystemTest < ApplicationSystemTestCase
  test '#create' do
    visit new_user_password_path

    within 'form.login-form' do
      fill_in 'user[email]', with: users(:customer).email
      click_on I18n.t('app.forgotten_password.form_submit')
    end
    assert_selector 'div.flash', text: I18n.t('devise.passwords.send_instructions')
  end
end
