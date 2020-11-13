# frozen_string_literal: true

require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  setup do
    @full_content = { subscription_period: subscription_periods(:customer_1_subscription_1_period),
                      copied_order: orders(:customer_order_1),
                      unconfirmed_copied_order: orders(:customer_order_1),
                      user: users(:customer),
                      delivery_date_from: 2.day.from_now,
                      delivery_date_to: 2.days.from_now + 3.hours,
                      position: 1 }
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

  test 'the validity - without copied_order is valid' do
    model = Order.new @full_content.except(:copied_order)
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without unconfirmed_copied_order is valid' do
    model = Order.new @full_content.except(:unconfirmed_copied_order)
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without delivery_date_from is not valid' do
    invalid_with_missing Order, :delivery_date_from
  end

  test 'the validity - without delivery_date_to is not valid' do
    invalid_with_missing Order, :delivery_date_to
  end

  test 'the validity - without position is not valid' do
    invalid_with_missing Order, :position
  end

  test '#delivery_date' do
    assert_equal "#{@order.delivery_date_from.strftime('%l:%M %P')} - #{@order.delivery_date_to.strftime('%l:%M %P')}, #{@order.delivery_date_to.strftime('%e %B')}",
                 @order.delivery_date
  end

  test '#delivered?' do
    assert @order.delivered?

    @order.update! delivery_date_to: 1.day.from_now
    refute @order.delivered?
  end

  test '#editable_till' do
    assert_equal (@order.delivery_date_from - Rails.application.config.options[:locked_before_delivery].days).end_of_day,
                 @order.editable_till
  end

  test '#placed?' do
    refute @order.placed?

    @order.order_state_relations.create! order_state: order_states(:order_placed)
    assert @order.reload.placed?
  end

  test '#finalised?' do
    refute @order.finalised?

    @order.order_state_relations.create! order_state: order_states(:finalised)
    assert @order.reload.finalised?
  end

  test '#editable?' do
    assert @order.editable?

    @order.order_state_relations.create! order_state: order_states(:finalised)
    refute @order.reload.editable?
  end
end
