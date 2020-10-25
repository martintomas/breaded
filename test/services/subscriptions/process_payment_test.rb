# frozen_string_literal: true

require 'test_helper'

class Subscriptions::ProcessPaymentTest < ActiveSupport::TestCase
  setup do
    @subscription = subscriptions :customer_subscription_1
    @subscription_period = subscription_periods :customer_1_subscription_1_period

    @checkout_params = object_to_methods JSON.parse(file_fixture('stripe/checkout_session_completed.json').read)
    @checkout_params['data']['object'].metadata['subscription_id'] = @subscription.id
    @invoice_paid_params = object_to_methods JSON.parse(file_fixture('stripe/invoice_paid.json').read)
    @invoice_payment_failed_params = object_to_methods JSON.parse(file_fixture('stripe/invoice_payment_failed.json').read)
  end

  test '#perform - checkout.session.completed updates stripe_subscription' do
    Subscriptions::ProcessPayment.new(@checkout_params).perform

    @subscription.reload
    assert_equal "NEW CHECKOUT SUBSCRIPTION", @subscription.stripe_subscription
    assert @subscription.active
  end

  test '#perform - checkout.session.completed creates payment record' do
    assert_difference -> { Payment.count }, 1 do
      Subscriptions::ProcessPayment.new(@checkout_params).perform

      payment = Payment.last
      assert_equal @subscription.subscription_plan.price, payment.price
      assert_equal @subscription.subscription_plan.currency, payment.currency
    end
  end

  test '#perform - checkout.session.completed updates future unpaid subscription period' do
    travel_to Time.zone.parse('24th Oct 2020 04:00:00') do
      @subscription_period.update! paid: false, started_at: Time.zone.parse('25th Oct 2020 04:00:00'),
                                   ended_at: Time.zone.parse('25th Nov 2020 04:00:00')
      Subscription.stub_any_instance :subscription_periods, SubscriptionPeriod.where(id: @subscription_period.id) do
        Subscriptions::ProcessPayment.new(@checkout_params).perform
        
        assert @subscription_period.reload.paid
      end
    end
  end

  test '#perform - checkout.session.completed updates running unpaid subscription period and moves her to future' do
    travel_to Time.zone.parse('24th Oct 2020 04:00:00') do
      @subscription_period.update! paid: false, started_at: Time.zone.parse('20th Oct 2020 05:00:00'),
                                   ended_at: Time.zone.parse('20th Nov 2020 05:00:00')
      Subscription.stub_any_instance :subscription_periods, SubscriptionPeriod.where(id: @subscription_period.id) do
        SubscriptionPeriods::Move.stub_any_instance :subscription_periods, [@subscription_period] do
          Subscriptions::ProcessPayment.new(@checkout_params).perform

          assert @subscription_period.reload.paid
          assert_equal Time.zone.parse('24th Oct 2020 05:00:00').to_i, @subscription_period.started_at.to_i
          assert_equal Time.zone.parse('24th Nov 2020 05:00:00').to_i, @subscription_period.ended_at.to_i
        end
      end
    end
  end

  test '#perform - checkout.session.completed creates new subscription period when it is to late to move previous one' do
    travel_to Time.zone.parse('24th Oct 2020 04:00:00') do
      @subscription_period.update! paid: false, started_at: Time.zone.parse('23th Sep 2020 05:00:00'),
                                   ended_at: Time.zone.parse('23th Oct 2020 05:00:00')
      Subscription.stub_any_instance :subscription_periods, SubscriptionPeriod.where(id: @subscription_period.id) do
        assert_difference -> { SubscriptionPeriod.count }, 1 do
          Subscriptions::ProcessPayment.new(@checkout_params).perform

          subscription_period = SubscriptionPeriod.last
          assert_equal Time.zone.parse('24th Oct 2020 05:00:00').to_i, subscription_period.started_at.to_i
          assert_equal Time.zone.parse('24th Nov 2020 05:00:00').to_i, subscription_period.ended_at.to_i
        end
      end
    end
  end

  test '#perform - invoice.paid checkout is skipped when subscription_create' do
    assert_no_difference -> { Payment.count } do
      @invoice_paid_params['data']['object'].billing_reason = 'subscription_create'

      Subscriptions::ProcessPayment.new(@invoice_paid_params).perform
    end
  end

  test '#perform - invoice.paid payment is created when invoice is paid' do
    assert_difference -> { Payment.count }, 1 do
      @invoice_paid_params['data']['object'].billing_reason = 'manual'

      Subscriptions::ProcessPayment.new(@invoice_paid_params).perform
    end
  end

  test '#perform - invoice.payment_failed is taken into account' do
    Subscriptions::ProcessPayment.new(@invoice_payment_failed_params).perform
  end

  private

  def object_to_methods(data)
    data['data']['object'] = OpenStruct.new data['data']['object']
    data
  end
end
