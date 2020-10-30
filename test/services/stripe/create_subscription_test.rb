# frozen_string_literal: true

require 'test_helper'

class Stripe::CreateSubscriptionTest < ActiveSupport::TestCase
  setup do
    @subscription = subscriptions :customer_subscription_1
    @service = Stripe::CreateSubscription.new @subscription
  end

  test '#perform_for - raise card error' do
    @subscription.user.update! stripe_customer: 'stripe_customer_id'

    Stripe::PaymentMethod.stub :attach, -> (*) { raise Stripe::CardError.new('test', {})} do
      @service.perform_for 'stripe_payment_method_id'
      assert_equal ['test'], @service.errors
    end
  end
  
  test '#perform_for - creates subscription for user with stripe customer id' do
    @subscription.user.update! stripe_customer: 'stripe_customer_id'

    Stripe::PaymentMethod.stub :attach, true, ['stripe_payment_method_id', { customer: 'stripe_customer_id' }] do
      Stripe::Customer.stub :update, true, ['stripe_customer_id',
                                            invoice_settings: { default_payment_method: 'stripe_payment_method_id' }] do
        Stripe::Subscription.stub :create, true, [customer: 'stripe_customer_id',
                                                  items: [{ price: @subscription.subscription_plan.stripe_price }],
                                                  expand: %w[latest_invoice.payment_intent],
                                                  metadata: { subscription_id: @subscription.id }] do
          @service.perform_for 'stripe_payment_method_id'
          assert_empty @service.errors
        end
      end
    end
  end

  test '#perform_for - creates subscription for user without stripe customer id' do
    Stripe::Customer.stub :create, OpenStruct.new(id: 'stripe_customer_id'), [email: @subscription.user.email] do
      Stripe::PaymentMethod.stub :attach, true, ['stripe_payment_method_id', { customer: 'stripe_customer_id' }] do
        Stripe::Customer.stub :update, true, ['stripe_customer_id',
                                              invoice_settings: { default_payment_method: 'stripe_payment_method_id' }] do
          Stripe::Subscription.stub :create, true, [customer: 'stripe_customer_id',
                                                    items: [{ price: @subscription.subscription_plan.stripe_price }],
                                                    expand: %w[latest_invoice.payment_intent],
                                                    metadata: { subscription_id: @subscription.id }] do
            @service.perform_for 'stripe_payment_method_id'
            assert_empty @service.errors
          end
        end
      end
    end
  end
end
