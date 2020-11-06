# frozen_string_literal: true

class Stripe::CreateSubscription
  attr_accessor :subscription, :errors

  def initialize(subscription)
    @subscription = subscription
    @errors = []
  end

  def perform_for(payment_method_id)
    run_stripe_actions_for payment_method_id unless already_paid?
  rescue Stripe::CardError => e
    errors << e.message
  end

  private

  def run_stripe_actions_for(payment_method_id)
    Stripe::PaymentMethod.attach payment_method_id, { customer: stripe_customer_id }
    Stripe::Customer.update stripe_customer_id, invoice_settings: { default_payment_method: payment_method_id }
    Stripe::Subscription.create customer: stripe_customer_id,
                                items: [{ price: subscription.subscription_plan.stripe_price }],
                                expand: %w[latest_invoice.payment_intent],
                                metadata: { subscription_id: subscription.id }
  end

  def already_paid?
    errors << I18n.t('app.stripe.subscription_already_paid') if subscription.active?
    errors.present?
  end

  def stripe_customer_id
    @stripe_customer_id ||= begin
      Stripe::UpdateCustomerJob.perform_now subscription.user if subscription.user.stripe_customer.blank?
      subscription.user.stripe_customer
    end
  end
end
