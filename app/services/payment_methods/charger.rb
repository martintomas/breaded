# frozen_string_literal: true

class PaymentMethods::Charger
  attr_accessor :subscription_plan, :user, :token, :error

  def initialize(user, subscription_plan, token)
    @user = user
    @subscription_plan = subscription_plan
    @token = token
  end

  def charge!
    puts customer_id.inspect
    puts (subscription_plan.price * 100).to_i
    Stripe::Charge.create customer: customer_id,
                          amount: (subscription_plan.price * 100).to_i,
                          description: subscription_plan.to_s,
                          currency: subscription_plan.currency.code.downcase
  rescue Stripe::CardError => e
    self.error = e.message
  end

  private

  def customer_id
    puts user.stripe_customer_id.inspect
    return user.stripe_customer_id if user.stripe_customer_id.present?

    customer = Stripe::Customer.create(email: user.email, source: @token)
    user.update! stripe_customer_id: customer.id
    customer.id
  end
end
