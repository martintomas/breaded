# frozen_string_literal: true

require 'test_helper'

class Admin::SubscriptionsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @subscription = subscriptions :customer_subscription_1
  end

  test 'is shown at menu' do
    get admin_subscriptions_url
    assert_select 'div.header' do
      assert_select 'li.menu_item.current' do
        assert_select 'a', I18n.t('active_admin.menu.parents.order')
        assert_select 'ul.menu' do
          assert_select 'li', I18n.t('active_admin.subscriptions.label')
        end
      end
    end
  end

  test 'shows proper title' do
    get admin_subscriptions_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', I18n.t('active_admin.subscriptions.label')
    end
  end

  test '#index' do
    get admin_subscriptions_url
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.paginated_collection' do
          assert_select 'table#index_table_subscriptions' do
            Subscription.all.each do |subscription|
              assert_select 'tr' do
                assert_select 'td', subscription.user.email
                assert_select 'td', subscription.subscription_plan.to_s
              end
            end
          end
        end
      end
    end
  end

  test '#show' do
    get admin_subscription_url(@subscription)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', @subscription.to_s
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.panel' do
          assert_select 'table' do
            assert_select 'td', @subscription.user.email
            assert_select 'td', @subscription.subscription_plan.to_s
          end
        end
      end
    end
  end

  test '#show - orders and payments' do
    subscription = subscriptions :customer_subscription_1
    get admin_subscription_url(subscription)

    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.panel#orders' do
          assert_select 'table' do
            assert_select 'tr' do
              subscription.orders.each do |order|
                assert_select 'td', order.delivery_date
                assert_select 'td', order.created_at.strftime('%B %d, %Y %H:%M')
                assert_select 'td', I18n.t('active_admin.dashboards.see_detail')
              end
            end
          end
        end
        assert_select 'div.panel#payments' do
          assert_select 'table' do
            assert_select 'tr' do
              subscription.payments.each do |payment|
                assert_select 'td', payment.price.to_s
                assert_select 'td', payment.currency.to_s
                assert_select 'td', payment.created_at.strftime('%B %d, %Y %H:%M')
                assert_select 'td', I18n.t('active_admin.dashboards.see_detail')
              end
            end
          end
        end
      end
    end
  end

  test '#edit' do
    get edit_admin_subscription_url(@subscription)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'Edit Subscription'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'form' do
          assert_select 'select[name="subscription[subscription_plan_id]"]' do
            assert_select 'option[selected="selected"]', @subscription.subscription_plan.to_s
          end
          assert_select 'select[name="subscription[user_id]"]' do
            assert_select 'option[selected="selected"]', @subscription.user.to_s
          end
          assert_select 'input[name="subscription[number_of_items]"][value=?]', @subscription.number_of_items.to_s
          assert_select 'input[name="subscription[active]"][value=?]', (@subscription.active && 1 || 0).to_s
        end
      end
    end
  end
end
