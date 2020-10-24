# frozen_string_literal: true

require 'test_helper'

class Subscriptions::SubscribeTest < ActiveSupport::TestCase
  setup do
    @subscription = Subscription.create! subscription_plan: subscription_plans(:twice_every_month),
                                         user: users(:customer),
                                         active: true,
                                         number_of_items: 10
  end

  test '#initialize - delivery date is provided' do
    frozen_time = Time.current
    subscriber = Subscriptions::Subscribe.new @subscription, delivery_date: frozen_time
    assert_equal frozen_time, subscriber.delivery_date_subscription
    assert_equal frozen_time, subscriber.delivery_date_order
  end

  test '#initialize - delivery date is computed for subscription without any subscription periods' do
    frozen_time = Time.current
    travel_to frozen_time do
      subscriber = Subscriptions::Subscribe.new @subscription
      assert_equal frozen_time.to_i, subscriber.delivery_date_subscription.to_i
      assert_equal frozen_time.to_i, subscriber.delivery_date_order.to_i
    end
  end

  test '#initialize - delivery date is computed from past subscription period' do
    frozen_time = Time.current
    travel_to frozen_time do
      SubscriptionPeriod.create! subscription: @subscription, started_at: 10.days.ago, ended_at: 10.days.from_now
      subscriber = Subscriptions::Subscribe.new @subscription
      assert_equal 10.days.from_now.to_i, subscriber.delivery_date_subscription.to_i
      assert_equal 10.days.from_now.to_i, subscriber.delivery_date_order.to_i
    end
  end

  test '#initialize - subscription period exists but It is in the past already' do
    frozen_time = Time.current
    travel_to frozen_time do
      SubscriptionPeriod.create! subscription: @subscription, started_at: 20.days.ago, ended_at: 10.days.ago
      subscriber = Subscriptions::Subscribe.new @subscription
      assert_equal frozen_time.to_i, subscriber.delivery_date_subscription.to_i
      assert_equal frozen_time.to_i, subscriber.delivery_date_order.to_i
    end
  end

  test '#initialize - order at past subscription exists, try to use same dates' do
    travel_to DateTime.parse('26th Oct 2020 12:00:00') do
      subscription_period = SubscriptionPeriod.create! subscription: @subscription,
                                                       started_at: Time.zone.parse('1st Oct 2020 04:00:00'),
                                                       ended_at: Time.zone.parse('20th Oct 2020 04:00:00')
      Order.create! subscription_period: subscription_period, user: users(:customer),
                    delivery_date_from: Time.zone.parse('16th Oct 2020 10:00:00'),
                    delivery_date_to: Time.zone.parse('16th Oct 2020 14:00:00')

      subscriber = Subscriptions::Subscribe.new @subscription
      assert_equal Time.zone.parse('26th Oct 2020 04:00:00').to_i, subscriber.delivery_date_subscription.to_i
      assert_equal Time.zone.parse('30th Oct 2020 10:00:00').to_i, subscriber.delivery_date_order.to_i
    end
  end

  test '#perform - it creates one subscription period' do
    assert_difference -> { SubscriptionPeriod.count }, 1 do
      frozen_time = Time.current
        travel_to frozen_time do
        subscriber = Subscriptions::Subscribe.new @subscription
        subscriber.perform

        assert_equal frozen_time.to_i, subscriber.subscription_period.started_at.to_i
        assert_equal (frozen_time + 1.month).to_i, subscriber.subscription_period.ended_at.to_i
      end
    end
  end

  test '#perform - it creates one order for one month subscription plan' do
    @subscription.update! subscription_plan: subscription_plans(:once_every_month)
    assert_difference -> { Order.count }, 1 do
      travel_to DateTime.parse('1st Oct 2020 12:00:00') do
        subscriber = Subscriptions::Subscribe.new @subscription
        orders = subscriber.perform

        assert_equal Time.zone.parse('5th Oct 2020 10:00:00').to_i, orders.first.delivery_date_from.to_i
        assert_equal Time.zone.parse('5th Oct 2020 14:00:00').to_i, orders.first.delivery_date_to.to_i
      end
    end
  end

  test '#perform - new orders has correct states' do
    @subscription.update! subscription_plan: subscription_plans(:once_every_month)
    assert_difference -> { Order.count }, 1 do
      travel_to DateTime.parse('1st Oct 2020 12:00:00') do
        subscriber = Subscriptions::Subscribe.new @subscription
        order = subscriber.perform.first

        assert_equal 1, order.order_states.count
        assert_equal OrderState.the_new, order.order_states.first
      end
    end
  end

  test '#perform - it creates two orders for two month subscription plan' do
    @subscription.update! subscription_plan: subscription_plans(:twice_every_month)
    assert_difference -> { Order.count }, 2 do
      travel_to DateTime.parse('1st Oct 2020 12:00:00') do
        subscriber = Subscriptions::Subscribe.new @subscription
        orders = subscriber.perform

        assert_equal Time.zone.parse('5th Oct 2020 10:00:00').to_i, orders.first.delivery_date_from.to_i
        assert_equal Time.zone.parse('5th Oct 2020 14:00:00').to_i, orders.first.delivery_date_to.to_i
        assert_equal Time.zone.parse('19th Oct 2020 10:00:00').to_i, orders.second.delivery_date_from.to_i
        assert_equal Time.zone.parse('19th Oct 2020 14:00:00').to_i, orders.second.delivery_date_to.to_i
      end
    end
  end

  test '#perform - it creates four orders for four month subscription plan' do
    @subscription.update! subscription_plan: subscription_plans(:four_times_every_month)
    assert_difference -> { Order.count }, 4 do
      travel_to DateTime.parse('1st Oct 2020 12:00:00') do
        subscriber = Subscriptions::Subscribe.new @subscription
        orders = subscriber.perform

        assert_equal Time.zone.parse('5th Oct 2020 10:00:00').to_i, orders[0].delivery_date_from.to_i
        assert_equal Time.zone.parse('5th Oct 2020 14:00:00').to_i, orders[0].delivery_date_to.to_i
        assert_equal Time.zone.parse('12th Oct 2020 10:00:00').to_i, orders[1].delivery_date_from.to_i
        assert_equal Time.zone.parse('12th Oct 2020 14:00:00').to_i, orders[1].delivery_date_to.to_i
        assert_equal Time.zone.parse('19th Oct 2020 10:00:00').to_i, orders[2].delivery_date_from.to_i
        assert_equal Time.zone.parse('19th Oct 2020 14:00:00').to_i, orders[2].delivery_date_to.to_i
        assert_equal Time.zone.parse('26th Oct 2020 10:00:00').to_i, orders[3].delivery_date_from.to_i
        assert_equal Time.zone.parse('26th Oct 2020 14:00:00').to_i, orders[3].delivery_date_to.to_i
      end
    end
  end

  test '#perform - when run multiple times' do
    @subscription.update! subscription_plan: subscription_plans(:twice_every_month)
    assert_difference -> { Order.count }, 4 do
      travel_to Time.zone.parse('1st Oct 2020 12:00:00') do
        subscriber = Subscriptions::Subscribe.new @subscription
        first_orders = subscriber.perform
        assert_equal Time.zone.parse('1st Oct 2020 12:00:00').to_i, subscriber.subscription_period.started_at.to_i
        assert_equal Time.zone.parse('1st Nov 2020 12:00:00').to_i, subscriber.subscription_period.ended_at.to_i
        assert_equal Time.zone.parse('5th Oct 2020 10:00:00').to_i, first_orders.first.delivery_date_from.to_i
        assert_equal Time.zone.parse('5th Oct 2020 14:00:00').to_i, first_orders.first.delivery_date_to.to_i
        assert_equal Time.zone.parse('19th Oct 2020 10:00:00').to_i, first_orders.second.delivery_date_from.to_i
        assert_equal Time.zone.parse('19th Oct 2020 14:00:00').to_i, first_orders.second.delivery_date_to.to_i

        subscriber = Subscriptions::Subscribe.new @subscription
        second_orders = subscriber.perform
        assert_equal Time.zone.parse('1st Nov 2020 12:00:00').to_i, subscriber.subscription_period.started_at.to_i
        assert_equal Time.zone.parse('1st Dec 2020 12:00:00').to_i, subscriber.subscription_period.ended_at.to_i
        assert_equal Time.zone.parse('2dn Nov 2020 10:00:00').to_i, second_orders.first.delivery_date_from.to_i
        assert_equal Time.zone.parse('2dn Nov 2020 14:00:00').to_i, second_orders.first.delivery_date_to.to_i
        assert_equal Time.zone.parse('16th Nov 2020 10:00:00').to_i, second_orders.second.delivery_date_from.to_i
        assert_equal Time.zone.parse('16th Nov 2020 14:00:00').to_i, second_orders.second.delivery_date_to.to_i
      end
    end
  end
end
