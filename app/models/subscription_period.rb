class SubscriptionPeriod < ApplicationRecord
  belongs_to :subscription

  has_many :orders, dependent: :destroy
  has_many :payments, dependent: :restrict_with_exception

  validates :paid, inclusion: { in: [true, false] }
  validates :started_at, :ended_at, presence: true

  def to_s
    "#{subscription.to_s}: #{started_at.strftime('%e.%m. %Y')}-#{ended_at.strftime('%e.%m. %Y')}"
  end
end
