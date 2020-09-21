# frozen_string_literal: true

class Currency < BaseType
  has_many :subscription_plans, dependent: :destroy
  has_many :payments, dependent: :restrict_with_exception

  validates :symbol, presence: true
end
