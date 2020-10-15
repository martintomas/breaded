# frozen_string_literal: true

require 'test_helper'

class OrderFoodTest < ActiveSupport::TestCase
  setup do
    @full_content = { food: foods(:seeded_bread),
                      order: orders(:customer_order_2),
                      amount: 2,
                      automatic: false }
  end

  test 'the validity - empty is not valid' do
    model = OrderFood.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = OrderFood.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without food is not valid' do
    invalid_with_missing OrderFood, :food
  end

  test 'the validity - without order is not valid' do
    invalid_with_missing OrderFood, :order
  end

  test 'the validity - without amount is not valid' do
    invalid_with_missing OrderFood, :amount
  end

  test 'the validity - without automatic is valid' do
    model = OrderFood.new @full_content.except(:automatic)
    assert model.valid?, model.errors.full_messages
    refute model.automatic
  end

  test 'the validity - combination of food and order has to be unique' do
    OrderFood.create! @full_content
    refute OrderFood.new(@full_content).valid?
  end
end
