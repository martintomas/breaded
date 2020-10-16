# frozen_string_literal: true

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  setup do
    @full_content = { user: users(:customer),
                      subscription_plan: subscription_plans(:once_every_month),
                      number_of_orders_left: 0,
                      number_of_items: 10,
                      active: true }
    @subscription = subscriptions :customer_subscription_1
  end

  test 'the validity - empty is not valid' do
    model = Subscription.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = Subscription.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without user is not valid' do
    invalid_with_missing Subscription, :user
  end

  test 'the validity - without subscription_plan is not valid' do
    invalid_with_missing Subscription, :subscription_plan
  end

  test 'the validity - without number_of_orders_left is not valid' do
    invalid_with_missing Subscription, :number_of_orders_left
  end

  test 'the validity - without number_of_items is not valid' do
    invalid_with_missing Subscription, :number_of_items
  end

  test 'the validity - without active is valid' do
    model = Subscription.new @full_content.except(:active)
    assert model.valid?, model.errors.full_messages
    assert model.active
  end

  test '#to_s' do
    assert_equal "#{@subscription.user.first_name} #{@subscription.user.last_name} (#{@subscription.user.email})",
                 @subscription.to_s
  end
end
