# frozen_string_literal: true

class Subscriptions::AttachToUser

  attr_accessor :subscription, :errors

  def initialize(subscription)
    @subscription = subscription
    @errors = []
  end

  def perform_for(payment_method_id)
    run_stripe_actions_for payment_method_id
  rescue Stripe::CardError => e
    errors << e.error.message
  end

  private

  def run_stripe_actions_for(payment_method_id)
    Stripe::PaymentMethod.attach payment_method_id, { customer: stripe_customer_id }
    Stripe::Customer.update stripe_customer_id, invoice_settings: { default_payment_method: payment_method_id }
    Stripe::Subscription.create customer: stripe_customer_id,
                                items: [{ price: subscription.subscription_plan.stripe_price }],
                                expand: %w[latest_invoice.payment_intent]
  end

  def stripe_customer_id
    Stripe::UpdateCustomerJob.perform_now subscription.user if subscription.user.stripe_customer.blank?

    subscription.user.stripe_customer
  end
end