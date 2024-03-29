# frozen_string_literal: true

module Stripe
  class UpdateSubscriptionPlanJob < ApplicationJob
    queue_as :critical

    attr_accessor :subscription_plan

    def perform(subscription_plan)
      @subscription_plan = subscription_plan

      subscription_plan.with_lock do
        upsert_product!
        upsert_price!
        subscription_plan.save!
      end
    end

    private

    def upsert_product!
      return if subscription_plan.stripe_product.present?

      name = I18n.t("app.get_breaded.plans.version_#{subscription_plan.number_of_deliveries}",
                    num_breads: Rails.application.config.options[:default_number_of_breads])
      product = Stripe::Product.create name: name, description: name
      subscription_plan.stripe_product = product.id
    end

    def upsert_price!
      price = Stripe::Price.create unit_amount: (subscription_plan.price * 100).to_i,
                                   currency: subscription_plan.currency.code.downcase,
                                   product: subscription_plan.stripe_product,
                                   recurring: { interval: 'month' }
      subscription_plan.stripe_price = price.id
    end
  end
end
