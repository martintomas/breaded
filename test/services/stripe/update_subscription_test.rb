# frozen_string_literal: true

require 'test_helper'

class Stripe::UpdateSubscriptionTest < ActiveSupport::TestCase
  setup do
    @subscription = subscriptions :customer_subscription_1
    @subscription_plan = subscription_plans :four_times_every_month
    @service = Stripe::UpdateSubscription.new @subscription, @subscription_plan
  end

  test '#perform - not active subscription cannot be updated' do
    @subscription.update! active: false
    @service.perform
    refute @subscription.reload.active?
  end

  test '#perform' do
    @subscription.update! stripe_subscription: 'stripe_subscription'
    @subscription_plan.update! stripe_price: 'stripe_price'
    Stripe::Subscription.stub :retrieve, OpenStruct.new(items: OpenStruct.new(data: [OpenStruct.new(id: 'stripe_item_id')])),
                              ['stripe_subscription'] do
      Stripe::Subscription.stub :update, true, ['stripe_subscription',
                                                items: [{ id: 'stripe_item_id', price: 'stripe_price' }],
                                                proration_behavior: 'none'] do
        @service.perform
        assert_equal @subscription_plan, @subscription.reload.subscription_plan
      end
    end
  end
end
