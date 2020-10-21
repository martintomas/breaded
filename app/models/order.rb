# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :subscription_period
  belongs_to :user

  has_many :order_foods, dependent: :destroy
  has_many :order_state_relations, dependent: :destroy
  has_many :order_states, through: :order_state_relations
  has_many :order_surprises, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy

  accepts_nested_attributes_for :address

  validates :delivery_date_from, :delivery_date_to, presence: true

  delegate :subscription, to: :subscription_period

  def delivery_date
    "#{delivery_date_from.strftime('%e.%B %Y')} #{delivery_date_from.strftime('%I%p')}-#{delivery_date_to.strftime('%I%p')}"
  end
end
