# frozen_string_literal: true

require 'test_helper'

class Subscriptions::MarkAsPaidTest < ActiveSupport::TestCase
  setup do
    @subscription = subscriptions :customer_subscription_1
    @subscription_period = subscription_periods :customer_1_subscription_1_period
  end

  test '#perform -creates payment record' do
    assert_difference -> { Payment.count }, 1 do
      Subscriptions::MarkAsPaid.new(@subscription).perform

      payment = Payment.last
      assert_equal @subscription.subscription_plan.price, payment.price
      assert_equal @subscription.subscription_plan.currency, payment.currency
    end
  end

  test '#perform - updates future unpaid subscription period' do
    travel_to Time.zone.parse('24th Oct 2020 04:00:00') do
      @subscription_period.update! paid: false, started_at: Time.zone.parse('25th Oct 2020 04:00:00'),
                                   ended_at: Time.zone.parse('25th Nov 2020 04:00:00')
      Subscription.stub_any_instance :subscription_periods, SubscriptionPeriod.where(id: @subscription_period.id) do
        Subscriptions::MarkAsPaid.new(@subscription).perform

        assert @subscription_period.reload.paid
      end
    end
  end

  test '#perform - updates running unpaid subscription period and moves her to future' do
    travel_to Time.zone.parse('24th Oct 2020 04:00:00') do
      @subscription_period.update! paid: false, started_at: Time.zone.parse('20th Oct 2020 05:00:00'),
                                   ended_at: Time.zone.parse('20th Nov 2020 05:00:00')
      Subscription.stub_any_instance :subscription_periods, SubscriptionPeriod.where(id: @subscription_period.id) do
        SubscriptionPeriods::Move.stub_any_instance :subscription_periods, [@subscription_period] do
          Subscriptions::MarkAsPaid.new(@subscription).perform

          assert @subscription_period.reload.paid
          assert_equal Time.zone.parse('24th Oct 2020 05:00:00').to_i, @subscription_period.started_at.to_i
          assert_equal Time.zone.parse('24th Nov 2020 05:00:00').to_i, @subscription_period.ended_at.to_i
        end
      end
    end
  end

  test '#perform - creates new subscription period when it is to late to move previous one' do
    travel_to Time.zone.parse('24th Oct 2020 04:00:00') do
      @subscription_period.update! paid: false, started_at: Time.zone.parse('23th Sep 2020 05:00:00'),
                                   ended_at: Time.zone.parse('23th Oct 2020 05:00:00')
      Subscription.stub_any_instance :subscription_periods, SubscriptionPeriod.where(id: @subscription_period.id) do
        assert_difference -> { SubscriptionPeriod.count }, 1 do
          Subscriptions::MarkAsPaid.new(@subscription).perform

          subscription_period = SubscriptionPeriod.last
          assert_equal Time.zone.parse('24th Oct 2020 05:00:00').to_i, subscription_period.started_at.to_i
          assert_equal Time.zone.parse('24th Nov 2020 05:00:00').to_i, subscription_period.ended_at.to_i
        end
      end
    end
  end
end
