# frozen_string_literal: true

class StripeController < ApplicationController
  skip_before_action :authenticate_user!, only: :subscription_webhook
  before_action :set_subscription, except: :subscription_webhook

  def checkout_session
    checkout = Stripe::CreateCheckout.new(@subscription).perform
    render json: { errors: checkout.errors, response: { id: checkout.session_id }}.to_json
  end

  def create_subscription
    service = Stripe::CreateSubscription.new @subscription
    response = service.perform_for params[:payment_method_id]
    render json: { errors: service.errors, response: response }.to_json
  end

  def update_payment_method
    service = Stripe::UpdatePaymentMethod.new @subscription
    response = service.perform_for params[:payment_method_id]
    render json: { errors: service.errors, response: response }.to_json
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

  private

  def set_subscription
    @subscription = Subscription.find params[:subscription_id]
    authorize! :update, @subscription
  end
end
