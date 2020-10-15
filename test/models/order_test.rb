# frozen_string_literal: true

require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  setup do
    @full_content = { subscription: subscriptions(:customer_subscription_1),
                      user: users(:customer),
                      delivery_date: 2.day.from_now }
  end

  test 'the validity - empty is not valid' do
    model = Order.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = Order.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without subscription is not valid' do
    invalid_with_missing Order, :subscription
  end

  test 'the validity - without user is not valid' do
    invalid_with_missing Order, :user
  end

  test 'the validity - without delivery_date is not valid' do
    invalid_with_missing Order, :delivery_date
  end
end
