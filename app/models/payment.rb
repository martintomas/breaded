# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :subscription
  belongs_to :currency

  validates :price, presence: true
end
