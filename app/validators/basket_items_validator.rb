# frozen_string_literal: true

class BasketItemsValidator
  attr_accessor :resource, :basket_items

  def initialize(resource, basket_items)
    @resource = resource
    @basket_items = basket_items
  end

  def run_validations_for(shopping_basket_variant)
    validate_pick_up_items! if shopping_basket_variant == Orders::UpdateFromBasket::PICK_UP_TYPE
  end

  private

  def validate_pick_up_items!
    check_amount_of_items
    all_food_is_available
  end

  def check_amount_of_items
    num_of_items = basket_items.sum { |item| item[:amount].to_i }
    resource.errors.add(:base, :missing_items) if num_of_items < Rails.application.config.options[:default_number_of_breads]
    resource.errors.add(:base, :too_many_items) if num_of_items > Rails.application.config.options[:default_number_of_breads]
  end

  def all_food_is_available
    available_foods = Food.enabled.pluck(:id)
    basket_items.map do |item|
      resource.errors.add(:base, :missing_food_item, name: item[:name]) unless item[:id].in? available_foods
    end
  end
end
