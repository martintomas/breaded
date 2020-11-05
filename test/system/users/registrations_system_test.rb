# frozen_string_literal: true

require "application_system_test_case"

class Users::RegistrationsSystemTest < ApplicationSystemTestCase
  test '#create' do
    visit new_user_registration_path

    within 'form.login-form' do
      fill_in 'user[first_name]', with: 'First Name'
      fill_in 'user[last_name]', with: 'Last Name'
      fill_in 'user[email]', with: 'test@test.test'
      fill_in 'user[password]', with: 'password'
      click_on I18n.t('app.registration.registration_submit')
    end
    within 'ul.menu' do
      assert_selector 'li', text: 'First Name'
    end
  end
end
