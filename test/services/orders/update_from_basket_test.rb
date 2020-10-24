# frozen_string_literal: true

require 'test_helper'

class Orders::UpdateFromBasketTest < ActiveSupport::TestCase
  setup do
    @order = orders :customer_order_1
    @order.order_foods.delete_all
    @order.order_surprises.delete_all
  end

  test '#perform_for - add all foods to order' do
    basket_items = [{ id: foods(:rye_bread).id, amount: 5 }, { id: foods(:seeded_bread).id, amount: 2 }]
    assert_difference -> { OrderFood.count }, 2 do
      assert_no_difference -> { OrderSurprise.count } do
        Orders::UpdateFromBasket.new(@order, basket_items).perform_for Orders::UpdateFromBasket::PICK_UP_TYPE

        assert_equal 5, @order.order_foods.find_by_food_id(foods(:rye_bread).id).amount
        assert_equal 2, @order.order_foods.find_by_food_id(foods(:seeded_bread).id).amount
      end
    end
  end

  test '#perform_for - add all tags to order' do
    basket_items = [{ id: tags(:vegetarian_tag).id, amount: 5 }, { id: tags(:rye_tag).id, amount: nil }]
    assert_difference -> { OrderSurprise.count }, 2 do
      assert_no_difference -> { OrderFood.count } do
        Orders::UpdateFromBasket.new(@order, basket_items).perform_for Orders::UpdateFromBasket::SURPRISE_ME_TYPE

        assert_equal 5, @order.order_surprises.joins(:tag).where(tags: { id: tags(:vegetarian_tag) }).first.amount
        assert_nil @order.order_surprises.joins(:tag).where(tags: { id: tags(:rye_tag) }).first.amount
      end
    end
  end
end
