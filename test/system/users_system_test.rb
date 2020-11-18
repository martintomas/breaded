# frozen_string_literal: true

require "application_system_test_case"

class UsersSystemTest < ApplicationSystemTestCase
  setup do
    login_as_customer
    @user = users :customer
  end

  test '#edit' do
    visit edit_user_path(@user)

    within "form#edit_user_#{@user.id}" do
      fill_in 'user[first_name]', with: 'Updated First Name'
      fill_in 'user[last_name]', with: 'Updated Last Name'
      fill_in 'user[secondary_phone_number]', with: '+420123456789'
      fill_in 'user[email]', with: 'test@test.test'
      fill_in 'user[password]', with: '12345679'
      click_button I18n.t('app.users.edit.submit')
    end
    assert_current_path new_user_session_path
  end
end
