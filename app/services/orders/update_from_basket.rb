# frozen_string_literal: true

class Orders::UpdateFromBasket
  attr_accessor :order, :basket_items

  PICK_UP_TYPE = 'pick-up'.freeze
  SURPRISE_ME_TYPE = 'surprise-me'.freeze

  def initialize(order, basket_items)
    @order = order
    @basket_items = basket_items
  end

  def perform_for(shopping_basket_variant)
    return add_food_items! if shopping_basket_variant == PICK_UP_TYPE

    add_surprise_me_items!
  end

  private

  def add_food_items!
    basket_items.each do |item|
      order.order_foods.create! food_id: item[:id], amount: item[:amount], automatic: false
    end
  end

  def add_surprise_me_items!
    basket_items.each do |item|
      order.order_surprises.create! tag_id: item[:id], amount: item[:amount]
    end
  end
end
