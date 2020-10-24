# frozen_string_literal: true

require 'test_helper'

class BasketItemValidatorTest < ActiveSupport::TestCase
  setup do
    user = users :customer
    @former = Subscriptions::NewSubscriptionFormer.new user: user
  end

  test '#run_validations_for - minimum number required' do
    basket_items = [{ id: foods(:rye_bread).id, name: 'test', amount: 5 },
                    { id: foods(:seeded_bread).id, name: 'test 2', amount: Rails.application.config.options[:default_number_of_breads] - 6 }]
    BasketItemsValidator.new(@former, basket_items).run_validations_for Orders::UpdateFromBasket::PICK_UP_TYPE

    assert_equal :missing_items, @former.errors.details[:base].first[:error]
  end

  test '#run_validations_for - cannot have more food then required limit' do
    basket_items = [{ id: foods(:rye_bread).id, name: 'test', amount: 5 },
                    { id: foods(:seeded_bread).id, name: 'test 2', amount: Rails.application.config.options[:default_number_of_breads] }]
    BasketItemsValidator.new(@former, basket_items).run_validations_for Orders::UpdateFromBasket::PICK_UP_TYPE

    assert_equal :too_many_items, @former.errors.details[:base].first[:error]
  end

  test '#run_validations_for - all food has to be available' do
    basket_items = [{ id: 'WRONG_ID', name: 'test', amount: 5 },
                    { id: foods(:seeded_bread).id, name: 'test 2', amount: Rails.application.config.options[:default_number_of_breads] - 5 }]
    BasketItemsValidator.new(@former, basket_items).run_validations_for Orders::UpdateFromBasket::PICK_UP_TYPE

    assert_equal :missing_food_item, @former.errors.details[:base].first[:error]
  end

  test '#run_validations_for - no error when shopping basket is correct' do
    basket_items = [{ id: foods(:rye_bread).id, name: 'test', amount: 5 },
                    { id: foods(:seeded_bread).id, name: 'test 2', amount: Rails.application.config.options[:default_number_of_breads] - 5 }]
    BasketItemsValidator.new(@former, basket_items).run_validations_for Orders::UpdateFromBasket::PICK_UP_TYPE

    assert_empty @former.errors
  end
end
