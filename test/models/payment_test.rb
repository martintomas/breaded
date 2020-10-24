# frozen_string_literal: true

require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  setup do
    @full_content = { subscription_period: subscription_periods(:customer_1_subscription_1_period),
                      currency: currencies(:GBP),
                      price: 29.99 }
  end

  test 'the validity - empty is not valid' do
    model = Payment.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = Payment.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without subscription_period is not valid' do
    invalid_with_missing Payment, :subscription_period
  end

  test 'the validity - without currency is not valid' do
    invalid_with_missing Payment, :currency
  end

  test 'the validity - without price is not valid' do
    invalid_with_missing Payment, :price
  end
end
