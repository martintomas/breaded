# frozen_string_literal: true

require 'test_helper'

class SubscriptionPeriodTest < ActiveSupport::TestCase
  setup do
    @full_content = { subscription: subscriptions(:customer_subscription_1),
                      started_at: Time.current,
                      ended_at: Time.current + 1.month,
                      paid: true }
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

  test 'the validity - without enabled is valid' do
    model = Food.new @full_content.except(:enabled)
    assert model.valid?, model.errors.full_messages
    assert model.enabled
  end
end
