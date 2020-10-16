# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :subscription_plan
  belongs_to :user

  has_many :orders, dependent: :destroy
  has_many :subscription_surprises, dependent: :destroy
  has_many :payments, dependent: :restrict_with_exception

  validates :active, inclusion: { in: [true, false] }
  validates :number_of_orders_left, :number_of_items, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }

  def to_s
    "#{user.first_name} #{user.last_name} (#{user.email})"
  end
end
