# frozen_string_literal: true

module Stripe
  class UpdateCustomerJob < ApplicationJob
    queue_as :critical

    def perform(user)
      user.with_lock do
        return Stripe::Customer.update user.stripe_customer, email: user.email if user.stripe_customer.present?

        customer = Stripe::Customer.create email: user.email
        user.update! stripe_customer: customer.id
      end
    end
  end
end
