# frozen_string_literal: true

class Stripe::UpdatePaymentMethod
  attr_accessor :subscription, :errors

  def initialize(subscription)
    @subscription = subscription
    @errors = []
  end

  def perform_for(payment_method_id)
    Stripe::PaymentMethod.attach payment_method_id, customer: @subscription.user.stripe_customer
    stripe_customer = Stripe::Customer.update @subscription.user.stripe_customer,
                                              invoice_settings: { default_payment_method: payment_method_id }
    remove_old_payment_methods_for stripe_customer
    stripe_customer
  rescue Stripe::CardError => e
    errors << e.message
  end

  private

  def remove_old_payment_methods_for(customer)
   Stripe::PaymentMethod.list(customer: @subscription.user.stripe_customer, type: 'card').data.each do |payment_method|
     next if payment_method.id == customer.invoice_settings.default_payment_method

     Stripe::PaymentMethod.detach payment_method.id
    end
  end
end
