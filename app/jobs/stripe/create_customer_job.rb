# frozen_string_literal: true

module Stripe
  class CreateCustomerJob < ApplicationJob
    queue_as :critical

    def perform(user)
      customer = Stripe::Customer.create email: user.email
      user.update stripe_customer: customer.id
    end
  end
end
