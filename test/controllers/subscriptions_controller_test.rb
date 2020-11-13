# frozen_string_literal: true

require 'test_helper'

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

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
                                                    amount: Rails.application.config.options[:default_number_of_breads] - 5 }].to_json }
            assert_redirected_to new_subscription_payment_path(Subscription.last,
                                                               shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE)
          end
        end
      end
    end
  end

  test '#create - save failed' do
    assert_no_difference -> { Subscription.count } do
      assert_no_difference -> { SubscriptionPeriod.count } do
        assert_no_difference -> { Order.count } do
          post subscriptions_path, params: { subscriptions_new_subscription_former: { street: 'Street' },
                                             basket_items: [] }

          assert_response :success
        end
      end
    end
  end

  test '#show' do
    get subscription_path(@subscription)

    assert_response :success
  end

  test '#show - cannot see subscription of somebody else' do
    get subscription_path(subscriptions(:customer_subscription_2))

    assert_redirected_to root_url
  end

  test '#edit' do
    Stripe::Subscription.stub :retrieve, OpenStruct.new(current_period_end: 0), [''] do
      get edit_subscription_path(@subscription)

      assert_response :success
    end
  end

  test '#edit - cannot edit subscription of somebody else' do
    get edit_subscription_path(subscriptions(:customer_subscription_2))

    assert_redirected_to root_url
  end

  test '#update' do
    @subscription.update! stripe_subscription: 'stripe_subscription', active: true
    subscription_plan = subscription_plans :four_times_every_month
    subscription_plan.update! stripe_price: 'stripe_price'

    Stripe::Subscription.stub :retrieve, OpenStruct.new(items: OpenStruct.new(data: [OpenStruct.new(id: 'stripe_item_id')])),
                              ['stripe_subscription'] do
      Stripe::Subscription.stub :update, true, ['stripe_subscription',
                                                items: [{ id: 'stripe_item_id', price: 'stripe_price' }],
                                                proration_behavior: 'none'] do
        patch subscription_path(@subscription), params: { subscription: { subscription_plan_id: subscription_plan.id } }
        assert_redirected_to subscription_path(@subscription)

        @subscription.reload
        assert_equal subscription_plan, @subscription.subscription_plan
      end
    end
  end

  test '#update - cannot change subscription of somebody else' do
    patch subscription_path(subscriptions(:customer_subscription_2)),
          params: { subscription: { subscription_plan_id: subscription_plans(:four_times_every_month).id } }

    assert_redirected_to root_url
  end

  test '#cancel' do
    @subscription.update! stripe_subscription: 'stripe_subscription', active: true, to_be_canceled: false
    Stripe::Subscription.stub :update, true, ['stripe_subscription', cancel_at_period_end: true] do
      get cancel_subscription_path(@subscription)

      assert_redirected_to subscription_path(@subscription)
      assert @subscription.reload.to_be_canceled?
    end
  end

  test '#cancel - cannot cancel subscription of somebody else' do
    get cancel_subscription_path(subscriptions(:customer_subscription_2))

    assert_redirected_to root_url
  end

  test '#resume' do
    @subscription.update! stripe_subscription: 'stripe_subscription', active: true, to_be_canceled: true
    Stripe::Subscription.stub :update, true, ['stripe_subscription', cancel_at_period_end: false] do
      get resume_subscription_path(@subscription)

      assert_redirected_to subscription_path(@subscription)
      refute @subscription.reload.to_be_canceled?
    end
  end

  test '#resume - cannot resume subscription of somebody else' do
    get resume_subscription_path(subscriptions(:customer_subscription_2))

    assert_redirected_to root_url
  end
end
