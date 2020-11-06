# frozen_string_literal: true

require 'test_helper'

class SubscriptionPeriodTest < ActiveSupport::TestCase
  setup do
    @full_content = { subscription: subscriptions(:customer_subscription_1),
                      started_at: Time.current,
                      ended_at: Time.current + 1.month,
                      paid: true }
    @subscription_period = subscription_periods :customer_1_subscription_1_period
  end

  test 'the validity - empty is not valid' do
    model = SubscriptionPeriod.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = SubscriptionPeriod.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without subscription is not valid' do
    invalid_with_missing SubscriptionPeriod, :subscription
  end

  test 'the validity - without started_at is not valid' do
    invalid_with_missing SubscriptionPeriod, :started_at
  end

  test 'the validity - without ended_at is not valid' do
    invalid_with_missing SubscriptionPeriod, :ended_at
  end

  test 'the validity - without paid is valid' do
    model = SubscriptionPeriod.new @full_content.except(:paid)
    assert model.valid?, model.errors.full_messages
    refute model.paid
  end

  test 'to_s' do
    assert_equal "#{@subscription_period.subscription.to_s}:#{@subscription_period.started_at.strftime('%e.%m. %Y')}-#{@subscription_period.ended_at.strftime('%e.%m. %Y')}",
                 @subscription_period.to_s
  end
end
