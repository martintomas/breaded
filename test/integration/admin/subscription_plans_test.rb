# frozen_string_literal: true

require 'test_helper'

class Admin::SubscriptionPlansTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @subscription_plan = subscription_plans :four_times_every_month
  end

  test 'is shown at menu' do
    get admin_subscription_plans_url
    assert_select 'div.header' do
      assert_select 'li.menu_item.current' do
        assert_select 'a', I18n.t('active_admin.menu.parents.order')
        assert_select 'ul.menu' do
          assert_select 'li', I18n.t('active_admin.subscription_plans.label')
        end
      end
    end
  end

  test 'shows proper title' do
    get admin_subscription_plans_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', I18n.t('active_admin.subscription_plans.label')
    end
  end

  test '#index' do
    get admin_subscription_plans_url
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.paginated_collection' do
          assert_select 'table#index_table_subscription_plans' do
            SubscriptionPlan.all.each do |subscription_plan|
              assert_select 'tr' do
                assert_select 'td', subscription_plan.number_of_deliveries.to_s
                assert_select 'td', subscription_plan.price.to_s
                assert_select 'td', subscription_plan.currency.to_s
              end
            end
          end
        end
      end
    end
  end

  test '#show' do
    get admin_subscription_plan_url(@subscription_plan)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', @subscription_plan.to_s
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.panel' do
          assert_select 'table' do
            assert_select 'td', @subscription_plan.number_of_deliveries.to_s
            assert_select 'td', @subscription_plan.price.to_s
            assert_select 'td', @subscription_plan.currency.to_s
          end
        end
      end
    end
  end

  test '#new' do
    get new_admin_subscription_plan_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'New Subscription Plan'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'form#new_subscription_plan' do
          assert_select 'input[name="subscription_plan[price]"]'
          assert_select 'input[name="subscription_plan[number_of_deliveries]"]'
          assert_select 'select[name="subscription_plan[currency_id]"]'
        end
      end
    end
  end

  test '#edit' do
    get edit_admin_subscription_plan_url(@subscription_plan)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'Edit Subscription Plan'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select "form#edit_subscription_plan" do
          assert_select 'input[name="subscription_plan[price]"][value=?]', @subscription_plan.price.to_s
          assert_select 'input[name="subscription_plan[number_of_deliveries]"][value=?]', @subscription_plan.number_of_deliveries.to_s
          assert_select 'select[name="subscription_plan[currency_id]"]' do
            assert_select 'option[selected=selected]', @subscription_plan.currency.to_s
          end
        end
      end
    end
  end
end
