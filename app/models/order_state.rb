# frozen_string_literal: true

class OrderState < BaseType
  has_many :order_state_relations, dependent: :destroy
end
