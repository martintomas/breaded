# frozen_string_literal: true

require 'test_helper'

class OrdersTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include SubscriptionPeriodsHelper
  include FoodsHelper

  setup do
    @user = users :customer
    @order = orders :customer_order_1
    sign_in @user
  end

  test '#show - pick breads order' do
    @order.update! delivery_date_to: 1.day.from_now
    get order_path(@order)

    assert_select 'h2', I18n.t('app.orders.show.bread_list', name: boxes_names_for(@order).titleize)
    assert_select 'span', I18n.t('app.orders.show.delivery_time', time_range: @order.delivery_date)
    assert_select '.specificPreferences', count: 0
    @order.order_foods.each_with_index do |order_food, i|
      assert_select 'ul.itemsection' do
        assert_select 'li' do
          assert_select 'span', order_food.food.localized_name
          assert_select 'i', "(#{order_food.amount})"
          assert_select 'p', order_food.food.localized_description
        end
      end
    end
  end

  test '#show - surprise me order' do
    order = orders :customer_surprise_order
    order.update! delivery_date_to: 1.day.from_now
    get order_path(order)

    assert_select 'h2', I18n.t('app.orders.show.bread_list', name: boxes_names_for(order).titleize)
    assert_select 'span', I18n.t('app.orders.show.delivery_time', time_range: order.delivery_date)
    assert_select '.specificPreferences span', I18n.t('app.orders.show.specific_preferences')
    orders(:customer_surprise_order).order_surprises.joins(:tag).where(tags: { tag_type_id: TagType.the_attribute.id }).each do |surprise_tag|
      assert_select 'ul' do
        assert_select 'li', I18n.t('app.orders.show.tag_name', tag: surprise_tag.tag.localized_name, count: surprise_tag.amount)
        assert_select 'li', "(#{surprise_tag.amount})"
      end
      assert_select 'p', I18n.t('app.orders.show.favourite_bread_types', tags: print_bread_preferences_for(order))
    end
  end

  test '#show - delivered order' do
    get order_path(@order)

    assert_select 'h2', I18n.t('app.orders.show.bread_list', name: boxes_names_for(@order).titleize)
    assert_select 'span.delivered', I18n.t('app.orders.show.delivered_at', date: @order.delivery_date_from.strftime('%e %B'))
  end
end
