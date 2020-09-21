# frozen_string_literal: true

require 'test_helper'

class FoodTagTest < ActiveSupport::TestCase
  setup do
    @full_content = { food: foods(:seeded_bread),
                      tag: tags(:vegetarian_tag) }
  end

  test 'the validity - empty is not valid' do
    model = FoodTag.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = FoodTag.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without food is not valid' do
    invalid_with_missing FoodTag, :food
  end

  test 'the validity - without tag is not valid' do
    invalid_with_missing FoodTag, :tag
  end

  test 'the validity - combination of food and tag has to be unique' do
    FoodTag.create! @full_content
    refute FoodTag.new(@full_content).valid?
  end
end
