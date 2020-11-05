# frozen_string_literal: true

require "application_system_test_case"

class Users::SessionsSystemTest < ApplicationSystemTestCase
  test 'can login as admin' do
    login_as_admin
    within 'ul#utility_nav' do
      assert_selector 'li#current_user', text: users(:admin).full_name
    end
  end

  test 'can login as customer' do
    login_as_customer
    within 'ul.menu' do
      assert_selector 'li', text: users(:customer).first_name
    end
  end

  test 'can logout after login' do
    login_as_customer
    within 'ul.menu' do
      assert_selector 'li', text: users(:customer).first_name
    end

    click_link users(:customer).first_name
    within 'ul.menu' do
      assert_selector 'li', text: I18n.t('app.menu.login')
    end
  end
end
