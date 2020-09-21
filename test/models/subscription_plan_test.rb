# frozen_string_literal: true

require 'test_helper'

class SubscriptionPlanTest < ActiveSupport::TestCase
  setup do
    @full_content = { price: 29.99,
                      currency: currencies(:GBP),
                      number_of_items: 10,
                      number_of_deliveries: 1 }
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

  test 'the validity - without number_of_items is not valid' do
    invalid_with_missing SubscriptionPlan, :number_of_items
  end

  test 'the validity - without number_of_deliveries is not valid' do
    invalid_with_missing SubscriptionPlan, :number_of_deliveries
  end
end
