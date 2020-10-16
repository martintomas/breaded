# frozen_string_literal: true

class SubscriptionPlan < ApplicationRecord
  belongs_to :currency

  has_many :subscriptions, dependent: :destroy

  validates :price, :number_of_deliveries, presence: true
  validates :number_of_deliveries, numericality: { greater_than_or_equal_to: 0 }

  def to_s
    "#{currency.code}: #{price}"
  end
end
