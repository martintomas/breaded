# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :subscription
  belongs_to :user

  has_many :order_foods, dependent: :destroy
  has_many :order_state_relations, dependent: :destroy
  has_many :order_states, through: :order_state_relations
  has_one :address, as: :addressable, dependent: :destroy

  validates :delivery_date, presence: true
end
