# frozen_string_literal: true

require 'test_helper'

class SubscriptionPlanTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @full_content = { price: 29.99,
                      currency: currencies(:GBP),
                      number_of_deliveries: 1 }
    @subscription_plan = subscription_plans :once_every_month
  end

  test 'the validity - empty is not valid' do
    model = SubscriptionPlan.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = SubscriptionPlan.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without price is not valid' do
    invalid_with_missing SubscriptionPlan, :price
  end

  test 'the validity - without currency is not valid' do
    invalid_with_missing SubscriptionPlan, :currency
  end

  test 'the validity - without number_of_deliveries is not valid' do
    invalid_with_missing SubscriptionPlan, :number_of_deliveries
  end

  test '#stripe_sync - is triggered after create' do
    assert_enqueued_jobs 1, only: Stripe::UpdateSubscriptionPlanJob do
      SubscriptionPlan.create! @full_content
    end
  end

  test '#stripe_sync - is triggered when price is updated' do
    assert_enqueued_jobs 1, only: Stripe::UpdateSubscriptionPlanJob do
      @subscription_plan.update! price: 10
    end
  end

  test '#stripe_sync - is triggered when currency is updated' do
    assert_enqueued_jobs 1, only: Stripe::UpdateSubscriptionPlanJob do
      @subscription_plan.update! currency: currencies(:EUR)
    end
  end

  test '#stripe_sync - is not triggered when different field of user is updated' do
    assert_no_enqueued_jobs only: Stripe::UpdateSubscriptionPlanJob do
      @subscription_plan.update! number_of_deliveries: 0
    end
  end

  test '#stripe_sync - is not triggered on destroy' do
    assert_no_enqueued_jobs only: Stripe::UpdateSubscriptionPlanJob do
      subscription_plans(:four_times_every_month).destroy!
    end
  end

  test '#to_s' do
    assert_equal "#{@subscription_plan.currency.code}: #{@subscription_plan.price}",
                 @subscription_plan.to_s
  end
end
