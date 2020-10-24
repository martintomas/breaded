# frozen_string_literal: true

class Subscriptions::Checkout
  include Rails.application.routes.url_helpers

  attr_accessor :subscription, :errors, :session_id

  def initialize(subscription)
    @subscription = subscription
    @errors = []
  end

  def perform
    errors << I18n.t('app.stripe.subscription_already_paid') if subscription.stripe_subscription.present?

    self.session_id = generate_session&.id
    self
  end

  private

  def generate_session
    return if errors.present?

    Stripe::Checkout::Session.create payment_method_types: ['card'],
                                     line_items: [{ price: subscription.subscription_plan.stripe_price, quantity: 1 }],
                                     mode: 'subscription',
                                     success_url: user_url(subscription.user, stripe_state: :success),
                                     cancel_url: user_url(subscription.user, stripe_state: :cancel),
                                     metadata: { subscription_id: subscription.id }
  end
end
