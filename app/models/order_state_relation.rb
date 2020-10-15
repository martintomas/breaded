# frozen_string_literal: true

class OrderStateRelation < ApplicationRecord
  belongs_to :order_state
  belongs_to :order

  validates_uniqueness_of :order_state_id, scope: :order_id
end
