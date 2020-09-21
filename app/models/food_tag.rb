# frozen_string_literal: true

class FoodTag < ApplicationRecord
  belongs_to :food
  belongs_to :tag

  validates_uniqueness_of :food_id, scope: :tag_id
end
