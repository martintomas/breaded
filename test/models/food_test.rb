# frozen_string_literal: true

require 'test_helper'

class FoodTest < ActiveSupport::TestCase
  setup do
    @full_content = { name: localised_texts(:rye_bread_name),
                      description: localised_texts(:rye_bread_description),
                      producer: producers(:bread_and_butter) }
    @food = foods :rye_bread
  end

  test 'the validity - empty is not valid' do
    model = Food.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = Food.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without name is not valid' do
    invalid_with_missing Food, :name
  end

  test 'the validity - without description is not valid' do
    invalid_with_missing Food, :description
  end

  test 'the validity - without producer is not valid' do
    invalid_with_missing Food, :producer
  end

  test '#to_s' do
    assert_equal @food.localized_name, @food.to_s
  end
end
