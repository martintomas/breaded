# frozen_string_literal: true

class Stripe::UpdateSubscription
  attr_accessor :subscription, :subscription_plan

  def initialize(subscription, subscription_plan)
    @subscription = subscription
    @subscription_plan = subscription_plan
  end

  def perform
    return unless subscription.active?

    Stripe::Subscription.update subscription.stripe_subscription,
                                items: [{ id: subscription.subscription_plan.stripe_price, price: subscription_plan.stripe_plan }],
                                proration_behavior: 'none'
    subscription.update! subscription_plan: subscription_plan
  end
end
