# frozen_string_literal: true

require 'test_helper'

class Admin::OrdersTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @order = orders :customer_order_1
  end

  test 'is shown at menu' do
    get admin_orders_url
    assert_select 'div.header' do
      assert_select 'li.menu_item.current' do
        assert_select 'a', I18n.t('active_admin.menu.parents.order')
        assert_select 'ul.menu' do
          assert_select 'li', I18n.t('active_admin.orders.label')
        end
      end
    end
  end

  test 'shows proper title' do
    get admin_orders_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', I18n.t('active_admin.orders.label')
    end
  end

  test '#index' do
    get admin_orders_url
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.paginated_collection' do
          assert_select 'table#index_table_orders' do
            Order.all.each do |order|
              assert_select 'tr' do
                assert_select 'td', order.user.email
                assert_select 'td', order.subscription.to_s
                assert_select 'td', order.delivery_date_from&.strftime('%B %d, %Y %H:%M')
                assert_select 'td', order.delivery_date_to&.strftime('%B %d, %Y %H:%M')
              end
            end
          end
        end
      end
    end
  end

  test '#show' do
    get admin_order_url(@order)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', "Order ##{@order.id}"
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.panel' do
          assert_select 'table' do
            assert_select 'td', @order.user.email
            assert_select 'td', @order.subscription_period.to_s
            assert_select 'td', @order.subscription.to_s
            assert_select 'td', @order.delivery_date_from&.strftime('%B %d, %Y %H:%M')
            assert_select 'td', @order.delivery_date_to&.strftime('%B %d, %Y %H:%M')
          end
        end
        assert_select 'div.panel#order_surprises' do
          assert_select 'table' do
            assert_select 'tr' do
              @order.order_surprises.each do |order_surprise|
                assert_select 'td', order_surprise.tag.to_s
                assert_select 'td', order_surprise.tag.tag_type.to_s
                assert_select 'td', order_surprise.amount.to_s if order_surprise.amount.present?
              end
            end
          end
        end
        assert_select 'div.panel#address' do
          assert_select 'table' do
            assert_select 'td', @order.address.address_line
            assert_select 'td', @order.address.street
            assert_select 'td', @order.address.postal_code.to_s
            assert_select 'td', @order.address.city
            assert_select 'td', @order.address.state
          end
        end
        assert_select 'div.panel#order_foods' do
          assert_select 'table' do
            assert_select 'tr' do
              @order.order_foods.each do |order_food|
                assert_select 'td', order_food.food.to_s
                assert_select 'td', order_food.amount.to_s
              end
            end
          end
        end
        assert_select 'div.panel#order_states' do
          assert_select 'table' do
            assert_select 'tr' do
              @order.order_states.each do |order_state|
                assert_select 'td', order_state.code
              end
            end
          end
        end
      end
    end
  end

  test '#show - order surprises' do
    order = orders :customer_surprise_order
    get admin_order_url(order)
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.panel#order_surprises' do
          assert_select 'table' do
            assert_select 'tr' do
              order.order_surprises.each do |order_surprise|
                assert_select 'td', order_surprise.tag.to_s
                assert_select 'td', order_surprise.tag.tag_type.to_s
                assert_select 'td', order_surprise.amount.to_s if order_surprise.amount.present?
              end
            end
          end
        end
      end
    end
  end

  test '#edit' do
    get edit_admin_order_url(@order)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'Edit Order'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'form' do
          assert_select 'select[name="order[subscription_period_id]"]' do
            assert_select 'option[selected="selected"]', @order.subscription_period.to_s
          end
          assert_select 'select[name="order[user_id]"]' do
            assert_select 'option[selected="selected"]', @order.user.to_s
          end
          assert_select 'input[name="order[address_attributes][address_line]"][value=?]', @order.address.address_line
          assert_select 'input[name="order[address_attributes][street]"][value=?]', @order.address.street
          assert_select 'input[name="order[address_attributes][postal_code]"][value=?]', @order.address.postal_code
          assert_select 'input[name="order[address_attributes][city]"][value=?]', @order.address.city
          assert_select 'input[name="order[address_attributes][state]"][value=?]', @order.address.state
        end
      end
    end
  end
end
