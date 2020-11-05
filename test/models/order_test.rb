# frozen_string_literal: true

require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  setup do
    @full_content = { subscription_period: subscription_periods(:customer_1_subscription_1_period),
                      user: users(:customer),
                      delivery_date_from: 2.day.from_now,
                      delivery_date_to: 2.days.from_now + 3.hours }
    @order = orders :customer_order_1
  end

  test 'the validity - empty is not valid' do
    model = Order.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = Order.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without subscription_period is not valid' do
    invalid_with_missing Order, :subscription_period
  end

  test 'the validity - without user is not valid' do
    invalid_with_missing Order, :user
  end

  test 'the validity - without delivery_date_from is not valid' do
    invalid_with_missing Order, :delivery_date_from
  end

  test 'the validity - without delivery_date_to is not valid' do
    invalid_with_missing Order, :delivery_date_to
  end

  test '#delivery_date' do
    assert_equal "#{@order.delivery_date_from.strftime('%l:%M %P')} - #{@order.delivery_date_to.strftime('%l:%M %P')}, #{@order.delivery_date_to.strftime('%e %B')}",
                 @order.delivery_date
  end
end
