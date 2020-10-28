# frozen_string_literal: true

require 'test_helper'

class StripeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users :customer
    @user.subscriptions.update_all active: false
  end

  test '#checkout_session' do
    sign_in @user
    Stripe::Checkout::Session.stub :create, OpenStruct.new(id: 'session_id') do
      post checkout_session_stripe_index_path, params: { subscription_id: subscriptions(:customer_subscription_1).id }

      assert_response :success
      body = JSON.parse(response.body).deep_symbolize_keys
      assert_equal [], body[:errors]
      assert_equal 'session_id', body[:response][:id]
    end
  end

  test '#checkout_session - forbidden when accessing subscription of somebody else' do
    sign_in @user
    post checkout_session_stripe_index_path, params: { subscription_id: subscriptions(:customer_subscription_2).id }

    assert_response :forbidden
  end

  test '#subscription_webhook' do
    Stripe::Webhook.stub :construct_event, {} do
      Subscriptions::ProcessPayment.stub :new, OpenStruct.new(perform: true) do
        post subscription_webhook_stripe_index_path

        assert_response :success
      end
    end
  end

  test '#subscription_webhook - when signature check fails' do
    Stripe::Webhook.stub :construct_event, -> (*) { raise Stripe::SignatureVerificationError.new 'failed', 'sig_header' } do
      post subscription_webhook_stripe_index_path

      assert_response :bad_request
    end
  end

  test '#create_subscription - success' do
    sign_in @user
    subscription = @user.subscriptions.first

    Stripe::Customer.stub :create, OpenStruct.new(id: 'stripe_customer_id'), [email: @user.email] do
      Stripe::PaymentMethod.stub :attach, true, ['stripe_payment_method_id', { customer: 'stripe_customer_id' }] do
        Stripe::Customer.stub :update, true, ['stripe_customer_id',
                                              invoice_settings: { default_payment_method: 'stripe_payment_method_id' }] do
          Stripe::Subscription.stub :create, 'subscription', [customer: 'stripe_customer_id',
                                                    items: [{ price: subscription.subscription_plan.stripe_price }],
                                                    expand: %w[latest_invoice.payment_intent]] do
            post create_subscription_stripe_index_path, params: { subscription_id: subscription.id }

            assert_response :success
            body = JSON.parse(response.body).deep_symbolize_keys
            assert_empty body[:errors]
            assert_equal 'subscription', body[:response]
          end
        end
      end
    end
  end

  test '#create_subscription - error' do
    sign_in @user

    Stripe::Customer.stub :create, OpenStruct.new(id: 'stripe_customer_id'), [email: @user.email] do
      Stripe::PaymentMethod.stub :attach, -> (*) { raise Stripe::CardError.new('test', {})} do
        post create_subscription_stripe_index_path, params: { subscription_id: @user.subscriptions.first.id }

        assert_response :success
        body = JSON.parse(response.body).deep_symbolize_keys
        assert_equal ['test'], body[:errors]
      end
    end
  end
end
