# frozen_string_literal: true

class Orders::Copy
  attr_accessor :order, :copied_order, :errors

  def initialize(order, copied_order)
    @order = order
    @copied_order = copied_order
    @errors = []
  end

  def perform
    ActiveRecord::Base.transaction do
      delete_current!
      copy_order_foods!
      copy_order_surprises!
      order.order_state_relations.create! order_state_id: OrderState.the_order_placed.id
    end
    errors.blank?
  end

  private

  def delete_current!
    order.order_foods.destroy_all
    order.order_surprises.destroy_all
  end

  def copy_order_foods!
    copied_order.order_foods.each do |order_food|
      order.order_foods.create! food_id: order_food.food_id, amount: order_food.amount
    end
  end

  def copy_order_surprises!
    copied_order.order_surprises.includes(:tag).each do |order_surprise|
      order.order_surprises.create! tag: order_surprise.tag, amount: order_surprise.amount
    end
  end
end
