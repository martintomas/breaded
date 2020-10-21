# frozen_string_literal: true

require "application_system_test_case"

class Admin::UsersSystemTest < ApplicationSystemTestCase
  setup do
    login_as_admin
    @user = users :customer
  end

  test '#create' do
    visit new_admin_user_url

    within 'form#new_user' do
      fill_in 'user[first_name]', with: 'First Name'
      fill_in 'user[last_name]', with: 'Last Name'
      fill_in 'user[email]', with: 'test@test.test'
      fill_in 'user[phone_number]', with: '123456789'
      fill_in 'user[password]', with: 'password'
      click_on 'Create User'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel:nth-of-type(1)' do
          within 'table' do
            assert_selector 'td', text: 'First Name'
            assert_selector 'td', text: 'Last Name'
            assert_selector 'td', text: 'test@test.test'
            assert_selector 'td', text: '123456789'
          end
        end
      end
    end
  end

  test '#update' do
    visit edit_admin_user_url(@user)

    within "form#edit_user_#{@user.id}" do
      fill_in 'user[first_name]', with: 'First Name'
      fill_in 'user[last_name]', with: 'Last Name'
      fill_in 'user[email]', with: 'test@test.test'
      fill_in 'user[password]', with: 'password'
      click_on 'Update User'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel:nth-of-type(1)' do
          within 'table' do
            assert_selector 'td', text: 'First Name'
            assert_selector 'td', text: 'Last Name'
            assert_selector 'td', text: 'test@test.test'
          end
        end
      end
    end
  end
end
