# frozen_string_literal: true

class PaymentMethods::Charger
  attr_accessor :subscription_plan, :user, :token, :error

  def initialize(user, subscription_plan, token: nil)
    @user = user
    @subscription_plan = subscription_plan
    @token = token
  end

  def charge!
    Stripe::Charge.create customer: customer_id,
                          amount: (subscription_plan.price * 100).to_i,
                          description: subscription_plan.to_s,
                          currency: subscription_plan.currency.code.downcase
  rescue Stripe::CardError => e
    self.error = I18n.t 'app.stripe.card_errors_message', message: e.error.message
  rescue Stripe::RateLimitError => e
    # Too many requests made to the API too quickly
  end

  private

  def customer_id
    return user.stripe_customer_id if user.stripe_customer_id.present?

    customer = Stripe::Customer.create email: user.email, source: @token
    user.update! stripe_customer_id: customer.id
    customer.id
  end
end
