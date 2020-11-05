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
    delete_current!
    return add_food_items! if shopping_basket_variant == PICK_UP_TYPE

    add_surprise_me_items!
  end

  private

  def delete_current!
    order.order_foods.destroy_all
    order.order_surprises.destroy_all
  end

  def add_food_items!
    basket_items.each do |item|
      order.order_foods.create! food_id: item[:id], amount: item[:amount], automatic: false
    end
  end

  def add_surprise_me_items!
    basket_items.each do |item|
      tag = tags[item[:id].to_i]
      next if tag.blank?

      order.order_surprises.create! tag: tag, amount: item[:amount]
    end
  end

  def tags
    @tags ||= begin
      records = Tag.where(id: basket_items.map { |i| i[:id] })
      records.each_with_object({}) { |record, result| result[record.id] = record }
    end
  end
end
