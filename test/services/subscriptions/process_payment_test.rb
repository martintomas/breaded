# frozen_string_literal: true

require 'test_helper'

class Subscriptions::ProcessPaymentTest < ActiveSupport::TestCase
  setup do
    @subscription = subscriptions :customer_subscription_1
    @subscription_period = subscription_periods :customer_1_subscription_1_period

    @subscription_created_params = object_to_methods JSON.parse(file_fixture('stripe/customer_subscription_created.json').read)
    @subscription_created_params['data']['object'].metadata['subscription_id'] = @subscription.id
    @subscription_deleted_params = object_to_methods JSON.parse(file_fixture('stripe/customer_subscription_deleted.json').read)
    @invoice_paid_params = object_to_methods JSON.parse(file_fixture('stripe/invoice_paid.json').read)
    @invoice_payment_failed_params = object_to_methods JSON.parse(file_fixture('stripe/invoice_payment_failed.json').read)
  end

  test '#perform - customer.subscription.created' do
    Subscriptions::ProcessPayment.new(@subscription_created_params).perform

    @subscription.reload
    assert_equal "NEW PAID SUBSCRIPTION", @subscription.stripe_subscription
    assert @subscription.active
    refute @subscription.to_be_canceled?
  end

  test '#perform - customer.subscription.deleted' do
    @subscription.update! stripe_subscription: 'NEW PAID SUBSCRIPTION'
    Subscriptions::ProcessPayment.new(@subscription_deleted_params).perform

    @subscription.reload
    assert_equal "NEW PAID SUBSCRIPTION", @subscription.stripe_subscription
    refute @subscription.active?
    assert @subscription.to_be_canceled?
  end

  test '#perform - invoice.paid marks subscription as active' do
    @subscription.update! stripe_subscription: 'NEW PAID SUBSCRIPTION'
    Subscriptions::ProcessPayment.new(@invoice_paid_params).perform

    @subscription.reload
    assert @subscription.active?
    refute @subscription.to_be_canceled?
  end

  test '#perform - invoice.paid creates payment record' do
    @subscription.update! stripe_subscription: 'NEW PAID SUBSCRIPTION'
    assert_difference -> { Payment.count }, 1 do
      Subscriptions::ProcessPayment.new(@invoice_paid_params).perform

      payment = Payment.last
      assert_equal @subscription.subscription_plan.price, payment.price
      assert_equal @subscription.subscription_plan.currency, payment.currency
    end
  end

  test '#perform - invoice.paid updates future unpaid subscription period' do
    @subscription.update! stripe_subscription: 'NEW PAID SUBSCRIPTION'
    travel_to Time.zone.parse('24th Oct 2020 04:00:00') do
      @subscription_period.update! paid: false, started_at: Time.zone.parse('25th Oct 2020 04:00:00'),
                                   ended_at: Time.zone.parse('25th Nov 2020 04:00:00')
      Subscription.stub_any_instance :subscription_periods, SubscriptionPeriod.where(id: @subscription_period.id) do
        Subscriptions::ProcessPayment.new(@invoice_paid_params).perform
        
        assert @subscription_period.reload.paid
      end
    end
  end

  test '#perform - invoice.paid updates running unpaid subscription period and moves her to future' do
    @subscription.update! stripe_subscription: 'NEW PAID SUBSCRIPTION'
    travel_to Time.zone.parse('24th Oct 2020 04:00:00') do
      @subscription_period.update! paid: false, started_at: Time.zone.parse('20th Oct 2020 05:00:00'),
                                   ended_at: Time.zone.parse('20th Nov 2020 05:00:00')
      @subscription_period.orders.first.update! delivery_date_from: Time.zone.parse('20th Oct 2020 05:00:00')
      Subscription.stub_any_instance :subscription_periods, SubscriptionPeriod.where(id: @subscription_period.id) do
        SubscriptionPeriods::Move.stub_any_instance :subscription_periods, [@subscription_period] do
          Subscriptions::ProcessPayment.new(@invoice_paid_params).perform

          assert @subscription_period.reload.paid
          assert_equal Time.zone.parse('24th Oct 2020 05:00:00').to_i, @subscription_period.started_at.to_i
          assert_equal Time.zone.parse('24th Nov 2020 05:00:00').to_i, @subscription_period.ended_at.to_i
        end
      end
    end
  end

  test '#perform - invoice.paid creates new subscription period when it is to late to move previous one' do
    @subscription.update! stripe_subscription: 'NEW PAID SUBSCRIPTION'
    travel_to Time.zone.parse('24th Oct 2020 04:00:00') do
      @subscription_period.update! paid: false, started_at: Time.zone.parse('23th Sep 2020 05:00:00'),
                                   ended_at: Time.zone.parse('23th Oct 2020 05:00:00')
      Subscription.stub_any_instance :subscription_periods, SubscriptionPeriod.where(id: @subscription_period.id) do
        assert_difference -> { SubscriptionPeriod.count }, 1 do
          Subscriptions::ProcessPayment.new(@invoice_paid_params).perform

          subscription_period = SubscriptionPeriod.last
          assert_equal Time.zone.parse('24th Oct 2020 05:00:00').to_i, subscription_period.started_at.to_i
          assert_equal Time.zone.parse('24th Nov 2020 05:00:00').to_i, subscription_period.ended_at.to_i
        end
      end
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
