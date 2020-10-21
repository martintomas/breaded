# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :subscription_period
  belongs_to :currency

  validates :price, presence: true

  delegate :subscription, to: :subscription_period
end
