# frozen_string_literal: true

require 'test_helper'

class StripeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Rails.application.routes.url_helpers

  setup do
    @user = users :customer
    @subscription = @user.subscriptions.first
    sign_in @user
  end

  test '#new' do
    get new_subscription_path, params: { shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE }

    assert_response :success
  end

  test '#create' do
    @user.subscriptions.update_all active: false

    travel_to Time.zone.parse('10th Oct 2020 10:00:00') do
      assert_difference -> { Address.count }, 1 do
        assert_difference -> { Subscription.count }, 1 do
          assert_difference -> { SubscriptionPeriod.count }, 1 do
            assert_difference -> { Order.count }, 1 do
              post subscriptions_path, params: { subscriptions_new_subscription_former:
                                                   { subscription_plan_id: subscription_plans(:once_every_month).id,
                                                     delivery_date_from: Time.zone.parse('19th Oct 2020 10:00:00'),
                                                     address_line: 'Address Line',
                                                     street: 'Street',
                                                     city: 'City',
                                                     postal_code: 'test',
                                                     shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE },
                                                 basket_items:
                                                   [{ id: foods(:rye_bread).id, amount: 5 },
                                                    { id: foods(:seeded_bread).id,
                                                      amount: Rails.application.config.options[:default_number_of_breads] - 5 }].to_json }, as: :json
              assert_response :success

              body = JSON.parse(response.body).deep_symbolize_keys
              assert_empty body[:errors]
              assert_equal Subscription.last.id, body[:response][:subscription_id]
              assert_equal checkout_session_stripe_index_path, body[:response][:stripe_checkout]
            end
          end
        end
      end
    end
  end

  test '#create - save failed' do
    assert_no_difference -> { Address.count } do
      assert_no_difference -> { Subscription.count } do
        assert_no_difference -> { SubscriptionPeriod.count } do
          assert_no_difference -> { Order.count } do
            post subscriptions_path, params: { subscriptions_new_subscription_former: { street: 'Street' },
                                               basket_items: [] }, as: :json

            assert_response :success
            body = JSON.parse(response.body).deep_symbolize_keys
            refute_empty body[:errors]
          end
        end
      end
    end
  end
end
