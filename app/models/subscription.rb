# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :subscription_plan
  belongs_to :user

  has_many :subscription_periods, dependent: :destroy
  has_many :orders, through: :subscription_periods
  has_many :payments, through: :subscription_periods

  validates :active, inclusion: { in: [true, false] }
  validates :number_of_items, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }

  def to_s
    "#{user.first_name} #{user.last_name} (#{user.email})"
  end
end
