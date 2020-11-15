# frozen_string_literal: true

require 'test_helper'

class SubscriptionPeriodsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users :customer
    @order = orders :customer_order_1
    sign_in @user
  end

  test '#show - editable order' do
    @order.update! delivery_date_to: 1.day.from_now

    get subscription_period_path(@order.subscription_period)
    assert_select "section.order-detail-section[data-order-id='#{@order.id}']" do
      assert_select 'label[for=pick_your_breads]', I18n.t('app.users.show.last_day_to_pick_your_breads') + @order.editable_till.strftime('%A, %d %b')
      assert_select 'a', text: I18n.t('app.users.show.delivery_time.change'), count: 2 # address and time change
    end
  end

  test '#show - finalised order cannot be edited' do
    @order.update! delivery_date_to: 1.day.from_now
    @order.order_state_relations.create! order_state: order_states(:finalised)

    get subscription_period_path(@order.subscription_period)
    assert_select "section.order-detail-section[data-order-id='#{@order.id}']" do
      assert_select 'label.OrderPlaced', count: 1
      assert_select 'a', text: I18n.t('app.users.show.delivery_time.change'), count: 0
    end
  end

  test '#show - delivered order cannot be edited' do
    @order.order_state_relations.create! order_state: order_states(:finalised)

    get subscription_period_path(@order.subscription_period)
    assert_select "section.order-detail-section[data-order-id='#{@order.id}']" do
      assert_select 'label.OrderDelivered', count: 1
      assert_select 'a', text: I18n.t('app.users.show.delivery_time.change'), count: 0
    end
  end
end
