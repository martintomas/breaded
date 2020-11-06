# frozen_string_literal: true

require 'test_helper'

class Orders::CopyTest < ActiveSupport::TestCase
  setup do
    @order_with_food = orders :customer_order_1
    @order_with_surprises = orders :customer_surprise_order
  end

  test '#perform - it deletes all old order foods' do
    Orders::Copy.new(@order_with_food, @order_with_surprises).perform

    assert_equal 0, @order_with_food.reload.order_foods.count
  end

  test '#perform - it deletes all old order surprises' do
    Orders::Copy.new(@order_with_surprises, @order_with_food).perform

    assert_equal 0, @order_with_surprises.reload.order_surprises.count
  end

  test '#perform - it copies order foods' do
    Orders::Copy.new(@order_with_surprises, @order_with_food).perform

    assert @order_with_surprises.reload.order_foods.count.positive?
    @order_with_surprises.reload.order_foods.each do |order_food|
      assert_equal order_food.amount, @order_with_food.order_foods.find_by_food_id(order_food.food_id).amount
    end
  end

  test '#perform - it copies order surprises' do
    Orders::Copy.new(@order_with_food, @order_with_surprises).perform

    assert @order_with_food.reload.order_surprises.count.positive?
    @order_with_food.reload.order_surprises.each do |order_surprise|
      assert_equal order_surprise.amount,
                   @order_with_surprises.order_surprises.joins(:tag).where(tags: { id: order_surprise.tag.id }).first.amount
    end
  end
end
