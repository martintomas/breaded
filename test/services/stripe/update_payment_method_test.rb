# frozen_string_literal: true

require 'test_helper'

class Stripe::UpdatePaymentMethodTest < ActiveSupport::TestCase
  setup do
    @subscription = subscriptions :customer_subscription_1
    @service = Stripe::UpdatePaymentMethod.new @subscription
  end

  test '#perform_for - attaches new payment method' do
    @subscription.user.update! stripe_customer: 'stripe_customer'

    with_payment_method_list do
      Stripe::PaymentMethod.stub :attach, true, ['payment_method_id', customer: 'stripe_customer'] do
        Stripe::Customer.stub :update, true,
                              ['stripe_customer',
                               invoice_settings: { default_payment_method: 'payment_method_id' }] do
          @service.perform_for 'payment_method_id'
          assert_empty @service.errors
        end
      end
    end
  end

  test '#perform_for - detaches all old payment methods' do
    @subscription.user.update! stripe_customer: 'stripe_customer'

    with_payment_method_list ids: %w[old_payment_method_id payment_method_id] do
      Stripe::PaymentMethod.stub :attach, true, ['payment_method_id', customer: 'stripe_customer'] do
        Stripe::Customer.stub :update, OpenStruct.new(invoice_settings: OpenStruct.new(default_payment_method: 'payment_method_id')),
                              ['stripe_customer',
                               invoice_settings: { default_payment_method: 'payment_method_id' }] do
          Stripe::PaymentMethod.stub :detach, true, ['old_payment_method_id'] do
            @service.perform_for 'payment_method_id'
            assert_empty @service.errors
          end
        end
      end
    end
  end

  test '#perform_for - raise card error' do
    @subscription.user.update! stripe_customer: 'stripe_customer_id'

    Stripe::PaymentMethod.stub :attach, -> (*) { raise Stripe::CardError.new('test', {})} do
      @service.perform_for 'stripe_payment_method_id'
      assert_equal ['test'], @service.errors
    end
  end

  private

  def with_payment_method_list(ids: [])
    Stripe::PaymentMethod.stub :list, OpenStruct.new(data: ids.map { |id| OpenStruct.new(id: id) }),
                               [@subscription.user.stripe_customer, type: 'card'] do
      yield
    end
  end
end
