# frozen_string_literal: true

class Subscriptions::ProcessPayment
  attr_accessor :stripe_event

  def initialize(stripe_event)
    @stripe_event = stripe_event
  end

  def perform
    case stripe_event['type']
    when 'invoice.paid'
      run_invoice_paid_actions
    when 'invoice.payment_failed'
      inform_user_about_fail
    end
  end

  private

  def run_invoice_paid_actions
    invoice = stripe_event['data']['object']
    Subscriptions::MarkAsPaid.new(subscription_from(invoice)).perform
  end

  def inform_user_about_fail
    invoice = stripe_event['data']['object']
    return unless invoice.attempt_count > 1

    # subscription = Subscription.find_by! stripe_subscription: invoice.subscription
    # TODO: inform user and prepare place where they can change their card
  end

  def subscription_from(invoice)
    Subscription.find_by! stripe_subscription: invoice.subscription unless invoice.billing_reason == 'subscription_create'

    Subscription.find(invoice.metadata['subscription_id']).tap do |subscription|
      subscription.update! stripe_subscription: invoice.subscription, active: true
    end
  end
end
