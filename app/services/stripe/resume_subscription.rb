# frozen_string_literal: true

class Stripe::ResumeSubscription
  attr_accessor :subscription

  def initialize(subscription)
    @subscription = subscription
  end

  def perform
    return if !subscription.to_be_canceled? || !subscription.active?

    Stripe::Subscription.update subscription.stripe_subscription, cancel_at_period_end: false
    subscription.update! to_be_canceled: false
  end
end
