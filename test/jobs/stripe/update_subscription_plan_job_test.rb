# frozen_string_literal: true

require 'test_helper'

class  Stripe::UpdateSubscriptionPlanJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @subscription_plan = subscription_plans :once_every_month
  end

  test '#perform - updates subscription_plan stripe price' do
    @subscription_plan.update! stripe_price: 'price_test', stripe_product: 'product_test'

    params = { unit_amount: (@subscription_plan.price * 100).to_i,
               currency: @subscription_plan.currency.code.downcase,
               product: 'product_test',
               recurring: { interval: 'month' } }
    Stripe::Price.stub :update, true, ['price_test', params] do
      Stripe::UpdateSubscriptionPlanJob.perform_now @subscription_plan
    end
  end

  test '#perform - creates stripe price and stripe product for new production plan' do
    name = I18n.t("app.get_breaded.plans.version_#{@subscription_plan.number_of_deliveries}",
                  num_breads: Rails.application.config.options[:default_number_of_breads])
    params = { unit_amount: (@subscription_plan.price * 100).to_i,
               currency: @subscription_plan.currency.code.downcase,
               product: 'product_test',
               recurring: { interval: 'month' } }

    Stripe::Product.stub :create, OpenStruct.new(id: 'product_test'), [name: name, description: name] do
      Stripe::Price.stub :create, OpenStruct.new(id: 'price_test'), [params] do
        assert_enqueued_jobs 0 do
          Stripe::UpdateSubscriptionPlanJob.perform_now @subscription_plan

          @subscription_plan.reload
          assert_equal 'product_test', @subscription_plan.stripe_product
          assert_equal 'price_test', @subscription_plan.stripe_price
        end
      end
    end
  end
end
