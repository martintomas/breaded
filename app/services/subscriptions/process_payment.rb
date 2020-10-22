# frozen_string_literal: true

class Subscriptions::ProcessPayment
  attr_accessor :stripe_event

  def initialize(stripe_event)
    @stripe_event = stripe_event
  end

  def perform
    case stripe_event['type']
    when 'checkout.session.completed'
      run_checkout_completed_actions
    when 'invoice.paid'
      run_invoice_paid_actions
    when 'invoice.payment_failed'
      inform_user_about_fail
    end
  end

  private

  def run_checkout_completed_actions
    checkout_session = stripe_event['data']['object']
    subscription = Subscription.find checkout_session['metadata']['subscription_id']
    subscription.update! stripe_subscription: checkout_session.subscription
    mark_paid! subscription
  end

  def run_invoice_paid_actions
    invoice = stripe_event.invoice
    return if invoice.billing_reason == 'subscription_create'

    subscription = Subscription.find_by! stripe_subscription: invoice.subscription
    mark_paid! subscription
  end

  def mark_paid!(subscription)
    subscription_period = subscription.subscription_periods.where(paid: false).where('ended_at >= ?', Time.current).order(:ended_at).first
    subscription_period ||= prepare_new_subscription_period_for! subscription
    subscription_period.update! paid: true
    subscription_period.payments.create! price: subscription.subscription_plan.price, currency: subscription.subscription_plan.currency
  end

  def inform_user_about_fail
    return unless stripe_event['data']['object']['attempt_count'] > 1

    # subscription = Subscription.find_by! stripe_subscription: stripe_event.invoice.subscription
    # TODO: inform user
  end

  def prepare_new_subscription_period_for!(subscription)
    subscriber = Subscriptions::Subscribe.new subscription
    subscriber.perform
    subscriber.subscription_period
  end
end
