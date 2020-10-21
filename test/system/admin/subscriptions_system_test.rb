# frozen_string_literal: true

require "application_system_test_case"

class Admin::SubscriptionsSystemTest < ApplicationSystemTestCase
  setup do
    login_as_admin
    @subscription = subscriptions :customer_subscription_1
  end

  test '#update' do
    visit edit_admin_subscription_url(@subscription)

    within "form#edit_subscription" do
      select SubscriptionPlan.first.to_s, from: 'subscription[subscription_plan_id]'
      select User.first.to_s, from: 'subscription[user_id]'
      fill_in 'subscription[number_of_items]', with: 50
      check 'subscription[active]'
      click_on 'Update Subscription'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel:nth-of-type(1)' do
          within 'table' do
            assert_selector 'td', text: SubscriptionPlan.first.to_s
            assert_selector 'td', text: User.first.email
            assert_selector 'td', text: 50
          end
        end
      end
    end
  end
end
