# frozen_string_literal: true

require 'test_helper'

class Stripe::CreateCheckoutTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  setup do
    @subscription = subscriptions :customer_subscription_1
  end

  test '#perform - one subscription cannot have checkout multiple times' do
    @subscription.update! stripe_subscription: 'DONE'

    checkout = Stripe::CreateCheckout.new(@subscription).perform
    assert_equal [I18n.t('app.stripe.subscription_already_paid')], checkout.errors
  end

  test '#perform - prepare checkout' do
    params = { payment_method_types: ['card'],
               line_items: [{ price: @subscription.subscription_plan.stripe_price, quantity: 1 }],
               mode: 'subscription',
               success_url: user_url(@subscription.user, stripe_state: :success),
               cancel_url: user_url(@subscription.user, stripe_state: :cancel),
               metadata: { subscription_id: @subscription.id } }

    Stripe::Checkout::Session.stub :create, OpenStruct.new(id: 'session_id'), [params] do
      checkout = Stripe::CreateCheckout.new(@subscription).perform
      assert_equal 'session_id', checkout.session_id
    end
  end
end
