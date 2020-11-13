# frozen_string_literal: true

require 'test_helper'

class Stripe::ResumeSubscriptionTest < ActiveSupport::TestCase
  setup do
    @subscription = subscriptions :customer_subscription_1
    @service = Stripe::ResumeSubscription.new @subscription
  end

  test '#perform - not canceled subscription cannot be resumed' do
    @subscription.update! to_be_canceled: false
    @service.perform
    refute @subscription.reload.to_be_canceled?
  end

  test '#perform - not active subscription cannot be resumed' do
    @subscription.update! active: false
    @service.perform
    refute @subscription.reload.active?
  end

  test '#perform - resume canceled subscription' do
    @subscription.update! active: true, to_be_canceled: true, stripe_subscription: 'stripe_subscription'
    Stripe::Subscription.stub :update, true, ['stripe_subscription', cancel_at_period_end: false] do
      @service.perform

      @subscription.reload
      refute @subscription.to_be_canceled?
      assert @subscription.active?
    end
  end
end
