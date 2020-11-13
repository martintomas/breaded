# frozen_string_literal: true

require 'test_helper'

class SubscriptionPeriods::MoveTest < ActiveSupport::TestCase
  setup do
    @subscription_period = subscription_periods :customer_1_subscription_1_period
    @subscription_period_2 = subscription_periods :customer_1_subscription_2_period
  end

  test '#perform - move is not required' do
    started_at_temp = @subscription_period.started_at
    SubscriptionPeriods::Move.new(@subscription_period, to: 1.month.ago).perform
    assert_equal started_at_temp, @subscription_period.reload.started_at
  end

  test '#perform - move is required' do
    started_at_temp = @subscription_period.started_at
    SubscriptionPeriods::Move.new(@subscription_period, to: 1.month.from_now).perform
    refute_equal started_at_temp, @subscription_period.reload.started_at
  end

  test '#perform - moves all influenced periods to future' do
    travel_to Time.zone.parse('10th Oct 2020 12:00:00') do
      move_subscriptions_to_past!
      move_orders_to_past!
      SubscriptionPeriods::Move.new(@subscription_period.reload, to: Time.zone.parse('19th Oct 2020 16:00:00')).perform

      @subscription_period.reload
      assert_equal Time.zone.parse('19th Oct 2020 12:00:00').to_i, @subscription_period.started_at.to_i
      assert_equal Time.zone.parse('19th Nov 2020 12:00:00').to_i, @subscription_period.ended_at.to_i

      @subscription_period_2.reload
      assert_equal Time.zone.parse('19th Nov 2020 12:00:00').to_i, @subscription_period_2.started_at.to_i
      assert_equal Time.zone.parse('19th Dec 2020 12:00:00').to_i, @subscription_period_2.ended_at.to_i
    end
  end

  test '#perform - moves all influenced orders to future' do
    travel_to Time.zone.parse('10th Oct 2020 12:00:00') do
      move_subscriptions_to_past!
      move_orders_to_past!
      SubscriptionPeriods::Move.new(@subscription_period.reload, to: Time.zone.parse('19th Oct 2020 16:00:00')).perform

      assert_equal Time.zone.parse('26th Oct 2020 10:00:00').to_i, orders(:customer_order_1).delivery_date_from.to_i
      assert_equal Time.zone.parse('26th Oct 2020 14:00:00').to_i, orders(:customer_order_1).delivery_date_to.to_i

      assert_equal Time.zone.parse('2nd Nov 2020 10:00:00').to_i, orders(:customer_surprise_order).delivery_date_from.to_i
      assert_equal Time.zone.parse('2nd Nov 2020 14:00:00').to_i, orders(:customer_surprise_order).delivery_date_to.to_i

      assert_equal Time.zone.parse('23th Nov 2020 10:00:00').to_i, orders(:customer_order_2).delivery_date_from.to_i
      assert_equal Time.zone.parse('23th Nov 2020 14:00:00').to_i, orders(:customer_order_2).delivery_date_to.to_i

      assert_equal Time.zone.parse('30th Nov 2020 10:00:00').to_i, orders(:customer_order_3).delivery_date_from.to_i
      assert_equal Time.zone.parse('30th Nov 2020 14:00:00').to_i, orders(:customer_order_3).delivery_date_to.to_i
    end
  end

  private

  def move_subscriptions_to_past!
    SubscriptionPeriod.order(:started_at).each_with_index { |s, i| s.update! started_at: Time.current + i.month }
  end

  def move_orders_to_past!
    Order.order(:delivery_date_from).each_with_index { |o, i| o.update! delivery_date_from: Time.current + i.week }
  end
end
