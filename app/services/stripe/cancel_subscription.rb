# frozen_string_literal: true

class Stripe::CancelSubscription
  attr_accessor :subscription

  def initialize(subscription)
    @subscription = subscription
  end

  def perform
    return if subscription.to_be_canceled? || !subscription.active?

    Stripe::Subscription.update subscription.stripe_subscription, cancel_at_period_end: true
    subscription.update! to_be_canceled: true
  end
end
