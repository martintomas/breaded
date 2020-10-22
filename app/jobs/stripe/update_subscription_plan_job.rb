# frozen_string_literal: true

module Stripe
  class UpdateSubscriptionPlanJob < ApplicationJob
    queue_as :critical

    attr_accessor :subscription_plan

    def perform(subscription_plan)
      @subscription_plan = subscription_plan
      subscription_plan.update! stripe_product: product.id, stripe_price: price.id, skip_stripe_sync: true
      # TODO: update also existing subscriptions
    end

    private

    def product
      name = I18n.t("app.get_breaded.plans.version_#{subscription_plan.number_of_deliveries}",
                    num_breads: Rails.application.config.options[:default_number_of_breads])

      @product ||= Stripe::Product.create name: name, description: name
    end

    def price
      @price ||= begin
        Stripe::Price.create product: product.id, unit_amount: (subscription_plan.price * 100).to_i,
                             currency: subscription_plan.currency.code.downcase, recurring: { interval: 'month' }
      end
    end
  end
end
