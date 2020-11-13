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

    assert_redirected_to root_url
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
          Stripe::Subscription.stub :create, OpenStruct.new(id: 'stripe_subscription', status: 'active'),
                                    [customer: 'stripe_customer_id',
                                     items: [{ price: subscription.subscription_plan.stripe_price }],
                                     expand: %w[latest_invoice.payment_intent],
                                     metadata: { subscription_id: subscription.id }] do
            post create_subscription_stripe_index_path, params: { subscription_id: subscription.id }

            assert_response :success
            body = JSON.parse(response.body).deep_symbolize_keys
            assert_empty body[:errors]
            assert_equal 'stripe_subscription', body[:response][:table][:id]
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

  test '#create_subscription - forbidden when accessing subscription of somebody else' do
    sign_in @user
    post create_subscription_stripe_index_path, params: { subscription_id: subscriptions(:customer_subscription_2).id }

    assert_redirected_to root_url
  end

  test '#update_payment_method - success' do
    sign_in @user
    subscription = @user.subscriptions.first
    subscription.user.update! stripe_customer: 'stripe_customer_id'

    Stripe::PaymentMethod.stub :list, OpenStruct.new(data: [OpenStruct.new(id: 'payment_method_id')]),
                               ['stripe_customer_id', type: 'card'] do
      Stripe::PaymentMethod.stub :attach, true, ['payment_method_id', customer: 'stripe_customer_id'] do
        Stripe::Customer.stub :update, OpenStruct.new(invoice_settings: OpenStruct.new(default_payment_method: 'payment_method_id')),
                              ['stripe_customer_id',
                               invoice_settings: { default_payment_method: 'payment_method_id' }] do
          post update_payment_method_stripe_index_path, params: { subscription_id: subscription.id }

          assert_response :success
          body = JSON.parse(response.body).deep_symbolize_keys
          assert_empty body[:errors]
          assert_equal 'payment_method_id', body[:response][:table][:invoice_settings][:table][:default_payment_method]
        end
      end
    end
  end

  test '#update_payment_method - error' do
    sign_in @user
    subscription = @user.subscriptions.first

    Stripe::PaymentMethod.stub :attach, -> (*) { raise Stripe::CardError.new('test', {})} do
      post update_payment_method_stripe_index_path, params: { subscription_id: subscription.id }

      assert_response :success
      body = JSON.parse(response.body).deep_symbolize_keys
      assert_equal ['test'], body[:errors]
    end
  end

  test '#update_payment_method - forbidden when accessing subscription of somebody else' do
    sign_in @user
    post update_payment_method_stripe_index_path, params: { subscription_id: subscriptions(:customer_subscription_2).id }

    assert_redirected_to root_url
  end
end
