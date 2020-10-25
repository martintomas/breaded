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
end
