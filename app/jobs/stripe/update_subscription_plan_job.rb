# frozen_string_literal: true

module Stripe
  class UpdateSubscriptionPlanJob < ApplicationJob
    queue_as :critical

    attr_accessor :subscription_plan

    def perform(subscription_plan)
      @subscription_plan = subscription_plan

      upsert_product!
      upsert_price!

      subscription_plan.skip_stripe_sync = true
      subscription_plan.save!
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
      params = { unit_amount: (subscription_plan.price * 100).to_i, currency: subscription_plan.currency.code.downcase }
      return Stripe::Price.update subscription_plan.stripe_price, params if subscription_plan.stripe_price.present?

      price = Stripe::Price.create({ product: subscription_plan.stripe_product, recurring: { interval: 'month' } }.merge(params))
      subscription_plan.stripe_price = price.id
    end
  end
end
