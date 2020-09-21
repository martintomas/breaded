# frozen_string_literal: true

class OrderFood < ApplicationRecord
  belongs_to :food
  belongs_to :order

  validates :amount, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates_uniqueness_of :food_id, scope: :order_id
end
