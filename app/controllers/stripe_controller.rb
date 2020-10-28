# frozen_string_literal: true

class StripeController < ApplicationController
  before_action :authenticate_user!, except: :subscription_webhook

  def checkout_session
    subscription = Subscription.find params[:subscription_id]
    return head :forbidden unless subscription.user == current_user

    checkout = Stripe::CreateCheckout.new(subscription).perform
    render json: { errors: checkout.errors, response: { id: checkout.session_id }}.to_json
  end

  def create_subscription
    service = Stripe::CreateSubscription.new Subscription.find(params[:subscription_id])
    subscription = service.perform_for params[:payment_method_id]
    render json: { errors: service.errors, response: subscription }.to_json
  end

  def subscription_webhook
    begin
      event = Stripe::Webhook.construct_event(request.body.read, request.env['HTTP_STRIPE_SIGNATURE'], ENV['STRIPE_WEBHOOK_SECRET'])
      Subscriptions::ProcessPayment.new(event).perform
      head :ok
    rescue JSON::ParserError, Stripe::SignatureVerificationError, ActiveRecord::RecordNotFound => e
      head :bad_request
    end
  end
end
