# frozen_string_literal: true

require "application_system_test_case"

class Admin::OrdersSystemTest < ApplicationSystemTestCase
  setup do
    login_as_admin
    @order = orders :customer_order_1
  end

  test '#update' do
    visit edit_admin_order_url(@order)

    within "form#edit_order_#{@order.id}" do
      select Subscription.first.to_s, from: 'order[subscription_id]'
      select User.first.to_s, from: 'order[user_id]'
      fill_in 'order[address_attributes][address_line]', with: 'Address Line'
      fill_in 'order[address_attributes][street]', with: 'Street'
      fill_in 'order[address_attributes][postal_code]', with: '123456'
      fill_in 'order[address_attributes][city]', with: 'City'
      fill_in 'order[address_attributes][state]', with: 'CZ'
      click_on 'Update Order'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel:nth-of-type(1)' do
          within 'table' do
            assert_selector 'td', text: User.first.email
            assert_selector 'td', text: Subscription.first.to_s
          end
        end
        within 'div.panel#address' do
          within 'table' do
            assert_selector 'td', text: 'Address Line'
            assert_selector 'td', text: 'Street'
            assert_selector 'td', text: '123456'
            assert_selector 'td', text: 'City'
            assert_selector 'td', text: 'CZ'
          end
        end
      end
    end
  end
end
