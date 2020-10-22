# frozen_string_literal: true

class SubscriptionPlan < ApplicationRecord
  attr_accessor :skip_stripe_sync

  belongs_to :currency

  has_many :subscriptions, dependent: :destroy

  validates :price, :number_of_deliveries, presence: true
  validates :number_of_deliveries, numericality: { greater_than_or_equal_to: 0 }

  after_save :stripe_sync, unless: :skip_stripe_sync

  def to_s
    "#{currency.code}: #{price}"
  end

  private

  def stripe_sync
    Stripe::UpdateSubscriptionPlanJob.perform_later self
  end
end
