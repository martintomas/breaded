# frozen_string_literal: true

require 'test_helper'

class Stripe::CancelSubscriptionTest < ActiveSupport::TestCase
  setup do
    @subscription = subscriptions :customer_subscription_1
    @service = Stripe::CancelSubscription.new @subscription
  end

  test '#perform - already canceled subscription is not canceled again' do
    @subscription.update! to_be_canceled: true
    @service.perform
    assert @subscription.reload.to_be_canceled?
  end

  test '#perform - not active subscription cannot be canceled' do
    @subscription.update! active: false
    @service.perform
    refute @subscription.reload.active?
  end

  test '#perform - cancel active subscription' do
    @subscription.update! active: true, to_be_canceled: false, stripe_subscription: 'stripe_subscription'
    Stripe::Subscription.stub :update, true, ['stripe_subscription', cancel_at_period_end: true] do
      @service.perform

      @subscription.reload
      assert @subscription.to_be_canceled?
      assert @subscription.active?
    end
  end
end
