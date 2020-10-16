# frozen_string_literal: true

require "application_system_test_case"

class Admin::SubscriptionPlansSystemTest < ApplicationSystemTestCase
  setup do
    login_as_admin
    @subscription_plan = subscription_plans :four_times_every_month
  end

  test '#create' do
    visit new_admin_subscription_plan_url

    within 'form#new_subscription_plan' do
      fill_in 'subscription_plan[price]', with: 11.5
      fill_in 'subscription_plan[number_of_deliveries]', with: 50
      select Currency.first.to_s, from: 'subscription_plan[currency_id]'
      click_on 'Create Subscription plan'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel:nth-of-type(1)' do
          within 'table' do
            assert_selector 'td', text: 11.5
            assert_selector 'td', text: 50
            assert_selector 'td', text: Currency.first.to_s
          end
        end
      end
    end
  end

  test '#update' do
    visit edit_admin_subscription_plan_url(@subscription_plan)

    within "form#edit_subscription_plan" do
      fill_in 'subscription_plan[price]', with: 11.5
      fill_in 'subscription_plan[number_of_deliveries]', with: 50
      select Currency.first.to_s, from: 'subscription_plan[currency_id]'
      click_on 'Update Subscription plan'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel:nth-of-type(1)' do
          within 'table' do
            assert_selector 'td', text: 11.5
            assert_selector 'td', text: 50
            assert_selector 'td', text: Currency.first.to_s
          end
        end
      end
    end
  end
end
