# frozen_string_literal: true

require 'test_helper'

class StripeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users :customer
    @order = orders :customer_order_2
    sign_in @user
  end

  test '#show' do
    get order_path(@order)

    assert_response :success
  end

  test '#show - order with surprises' do
    get order_path(orders(:customer_surprise_order))

    assert_response :success
  end

  test '#show - not allowed to see orders of different people' do
    get order_path(orders(:customer_2_order_1))

    assert_redirected_to root_url
  end

  test '#edit' do
    get edit_order_path(@order)

    assert_response :success
  end

  test '#edit - not allowed to edit orders of different people' do
    get edit_order_path(orders(:customer_2_order_1))

    assert_redirected_to root_url
  end

  test '#update' do
    patch order_path(@order), params: { shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE,
                                        basket_items: [{ id: foods(:rye_bread).id, amount: 5 },
                                                       { id: foods(:seeded_bread).id, amount: 5 }].to_json }

    assert_redirected_to subscription_period_path(@order.subscription_period)

    @order.reload
    assert_equal 2, @order.order_foods.count
    assert_equal 5, @order.order_foods.find_by_food_id(foods(:rye_bread).id).amount
    assert_equal 5, @order.order_foods.find_by_food_id(foods(:seeded_bread).id).amount
    assert @order.order_states.include?(order_states(:order_placed))
  end

  test '#update - already placed order cannot be updated again' do
    @order.order_state_relations.create! order_state: order_states(:order_placed)

    assert_no_difference -> { OrderFood.count } do
      assert_no_difference -> { OrderSurprise.count } do
        patch order_path(@order)

        assert_redirected_to subscription_period_path(@order.subscription_period)
      end
    end
  end

  test '#update - not allowed to edit orders of different people' do
    patch order_path(orders(:customer_2_order_1))

    assert_redirected_to root_url
  end

  test '#copy' do
    post copy_order_path(@order), params: { copy_order_id: orders(:customer_order_1).id }, as: :json

    assert_response :success
    body = JSON.parse(response.body).symbolize_keys
    refute_nil body[:order_detail]

    @order.reload
    assert_equal orders(:customer_order_1).order_foods.first.amount,
                 @order.order_foods.find_by_food_id(orders(:customer_order_1).order_foods.first.food_id).amount
    assert_equal orders(:customer_order_1).order_foods.last.amount,
                 @order.order_foods.find_by_food_id(orders(:customer_order_1).order_foods.last.food_id).amount
    assert @order.order_states.include?(order_states(:order_placed))
  end

  test '#copy - already placed order cannot be modified' do
    @order.order_state_relations.create! order_state: order_states(:order_placed)
    post copy_order_path(@order), params: { copy_order_id: orders(:customer_order_1).id }, as: :json

    assert_response :forbidden
  end

  test '#copy - not allowed to modify orders of different people' do
    post copy_order_path(orders(:customer_2_order_1)), params: { copy_order_id: @order.id }, as: :json

    assert_response :forbidden
  end

  test '#copy - not allowed to copy orders of different people' do
    post copy_order_path(@order), params: { copy_order_id: orders(:customer_2_order_1).id }, as: :json

    assert_response :forbidden
  end

  test '#update_date' do
    travel_to Time.zone.parse('10th Oct 2020 10:00:00') do
      post update_date_order_path(@order), params: { timestamp: Time.zone.parse('19th Oct 2020 10:00:00') }, as: :json

      assert_response :success
      @order.reload

      body = JSON.parse(response.body).symbolize_keys
      assert_equal @order.delivery_date_from.strftime('%A %d %b'), body[:delivery_date]
      assert_equal "#{@order.delivery_date_from.strftime('%l:%M %P')} - #{@order.delivery_date_to.strftime('%l:%M %P')}",
                   body[:delivery_date_range]

      assert_equal Time.zone.parse('19th Oct 2020 10:00:00').to_i, @order.delivery_date_from.to_i
      assert_equal Time.zone.parse('19th Oct 2020 14:00:00').to_i, @order.delivery_date_to.to_i
    end
  end

  test '#update_date - not allowed to update date of somebody else' do
    post update_date_order_path(orders(:customer_2_order_1)), params: { timestamp: Time.zone.parse('19th Oct 2020 10:00:00') }, as: :json

    assert_response :forbidden
  end

  test '#surprise_me' do
    get surprise_me_order_path(@order)

    assert_response :success
  end

  test '#surprise_me - not allowed to edit orders of different people' do
    get surprise_me_order_path(orders(:customer_2_order_1))

    assert_redirected_to root_url
  end
end
