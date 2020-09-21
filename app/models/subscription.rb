# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :subscription_plan
  belongs_to :user

  has_many :orders, dependent: :destroy
  has_one :payment, dependent: :restrict_with_exception

  validates :surprise_me_count, presence: true
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }
end
