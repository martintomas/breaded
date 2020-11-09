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
                                items: [{ id: stripe_item_id, price: subscription_plan.stripe_price }],
                                proration_behavior: 'none'
    subscription.update! subscription_plan: subscription_plan
  end

  private

  def stripe_item_id
    Stripe::Subscription.retrieve(subscription.stripe_subscription).items.data[0].id
  end
end
