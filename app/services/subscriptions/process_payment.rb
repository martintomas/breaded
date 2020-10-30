# frozen_string_literal: true

class Subscriptions::ProcessPayment
  attr_accessor :stripe_event

  def initialize(stripe_event)
    @stripe_event = stripe_event
  end

  def perform
    case stripe_event['type']
    when 'customer.subscription.created'
      register_subscription
    when 'invoice.paid'
      run_invoice_paid_actions
    when 'invoice.payment_failed'
      inform_user_about_fail
    end
  end

  private

  def register_subscription
    subscription = Subscription.find stripe_event['data']['object'].metadata['subscription_id']
    subscription.update! stripe_subscription: stripe_event['data']['object'].id, active: true
  end

  def run_invoice_paid_actions
    subscription = Subscription.find_by! stripe_subscription: stripe_event['data']['object'].subscription
    Subscriptions::MarkAsPaid.new(subscription).perform
  end

  def inform_user_about_fail
    invoice = stripe_event['data']['object']
    return unless invoice.attempt_count > 1

    # subscription = Subscription.find_by! stripe_subscription: invoice.subscription
    # TODO: inform user and prepare place where they can change their card
  end
end
