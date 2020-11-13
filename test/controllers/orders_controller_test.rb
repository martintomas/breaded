# frozen_string_literal: true

require 'test_helper'

class OrderControllerTest < ActionDispatch::IntegrationTest
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

  test '#confirm_update' do
    get confirm_update_order_path(@order), params: { shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE }

    assert_response :success
  end

  test '#confirm_update - cannot confirm update of somebody else' do
    get confirm_update_order_path(orders(:customer_2_order_1))

    assert_redirected_to root_url
  end

  test '#update' do
    travel_to Time.zone.parse('10th Oct 2020 10:00:00') do
      patch order_path(@order), params: { orders_update_former:
                                           { secondary_phone_number: '420999999999',
                                             delivery_date_from: '19th Oct 2020 10:00:00',
                                             address_line: 'Address Line',
                                             street: 'Street',
                                             city: 'City',
                                             postal_code: 'test',
                                             shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE },
                                         basket_items:
                                             [{ id: foods(:rye_bread).id, amount: 5 },
                                              { id: foods(:seeded_bread).id,
                                                amount: Rails.application.config.options[:default_number_of_breads] - 5 }].to_json }

      assert_redirected_to subscription_period_path(@order.subscription_period)

      @order.reload
      assert_equal 'Address Line', @order.address.address_line
      assert_equal 'Street', @order.address.street
      assert_equal 'City', @order.address.city
      assert_equal 'test', @order.address.postal_code
      assert_equal 'UK', @order.address.state
      assert_equal @user.reload.secondary_phone_number, '+420999999999'
      assert_equal Time.zone.parse('19th Oct 2020 10:00:00').to_i, @order.delivery_date_from.to_i
      assert_equal Time.zone.parse('19th Oct 2020 14:00:00').to_i, @order.delivery_date_to.to_i
      assert_equal 5, @order.order_foods.find_by_food_id(foods(:rye_bread).id).amount
      assert_equal Rails.application.config.options[:default_number_of_breads] - 5,
                   @order.order_foods.find_by_food_id(foods(:seeded_bread).id).amount
      assert @order.placed?
    end
  end

  test '#update - failed with error' do
    patch order_path(@order), params: { orders_update_former: { street: 'Street' }, basket_items: [] }

    assert_response :success
  end

  test '#update - cannot update order of somebody else' do
    patch order_path(orders(:customer_2_order_1))

    assert_redirected_to root_url
  end

  test '#pick_breads_option' do
    @order.update! copied_order: Order.first, unconfirmed_copied_order: Order.last
    @order.order_state_relations.create! order_state_id: OrderState.the_order_placed.id
    post pick_breads_option_order_path(@order), as: :json

    assert_response :success
    body = JSON.parse(response.body).symbolize_keys
    refute_nil body[:order_detail]

    @order.reload
    assert_nil @order.copied_order
    assert_nil @order.unconfirmed_copied_order
    refute @order.placed?
  end

  test '#pick_breads_option - cannot update not your order' do
    post pick_breads_option_order_path(orders(:customer_2_order_1)), as: :json

    assert_response :forbidden
  end

  test '#pick_breads_option - cannot update already finalised order' do
    @order.order_state_relations.create! order_state_id: OrderState.the_finalised.id
    post pick_breads_option_order_path(@order), as: :json

    assert_response :forbidden
  end

  test '#copy_order_option' do
    post copy_order_option_order_path(@order), params: { copy_order_id: orders(:customer_order_1).id }, as: :json

    assert_response :success
    body = JSON.parse(response.body).symbolize_keys
    refute_nil body[:order_detail]

    @order.reload
    assert_equal orders(:customer_order_1), @order.unconfirmed_copied_order
  end

  test '#copy_order_option - already confirmed option' do
    @order.update! copied_order: orders(:customer_order_1)
    post copy_order_option_order_path(@order), params: { copy_order_id: orders(:customer_order_1).id }, as: :json

    assert_response :success
    body = JSON.parse(response.body).symbolize_keys
    refute_nil body[:order_detail]

    @order.reload
    assert_nil @order.unconfirmed_copied_order
  end

  test '#copy_order_option - already finalised order cannot be modified' do
    @order.order_state_relations.create! order_state: order_states(:finalised)
    post copy_order_option_order_path(@order), params: { copy_order_id: orders(:customer_order_1).id }, as: :json

    assert_response :forbidden
  end

  test '#copy_order_option - not allowed to modify orders of different people' do
    post copy_order_option_order_path(orders(:customer_2_order_1)), params: { copy_order_id: @order.id }, as: :json

    assert_response :forbidden
  end

  test '#copy_order_option - not allowed to copy orders of different people' do
    post copy_order_option_order_path(@order), params: { copy_order_id: orders(:customer_2_order_1).id }, as: :json

    assert_response :forbidden
  end

  test '#confirm_copy_option' do
    @order.update! unconfirmed_copied_order: orders(:customer_order_1)
    post confirm_copy_option_order_path(@order), as: :json

    assert_response :success
    body = JSON.parse(response.body).symbolize_keys
    refute_nil body[:order_detail]

    @order.reload
    assert_nil @order.unconfirmed_copied_order
    assert_equal orders(:customer_order_1), @order.copied_order
    assert @order.placed?
    assert_equal orders(:customer_order_1).order_foods.first.amount,
                 @order.order_foods.find_by_food_id(orders(:customer_order_1).order_foods.first.food_id).amount
    assert_equal orders(:customer_order_1).order_foods.last.amount,
                 @order.order_foods.find_by_food_id(orders(:customer_order_1).order_foods.last.food_id).amount
    assert @order.order_states.include?(order_states(:order_placed))
  end

  test '#confirm_copy_option - already finalised order cannot be modified' do
    @order.order_state_relations.create! order_state: order_states(:finalised)
    post confirm_copy_option_order_path(@order), as: :json

    assert_response :forbidden
  end

  test '#confirm_copy_option - not allowed to modify orders of different people' do
    post confirm_copy_option_order_path(orders(:customer_2_order_1)), as: :json

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

  test '#update_address' do
    post update_address_order_path(@order), params: { address: { address_line: 'Address Line',
                                                                 street: 'Street' ,
                                                                 city: 'City',
                                                                 postal_code: 'Postal Code' } }, as: :json
    assert_response :success

    body = JSON.parse(response.body).symbolize_keys
    assert_equal 'Address Line', body[:address_line]
    assert_equal 'Street', body[:street]
    assert_equal 'City', body[:city]
    assert_equal 'Postal Code', body[:postal_code]

    @order.reload
    assert_equal 'Address Line', @order.address.address_line
    assert_equal 'Street', @order.address.street
    assert_equal 'City', @order.address.city
    assert_equal 'Postal Code', @order.address.postal_code
  end

  test '#update_address - create new one' do
    @order.address&.destroy
    assert_difference -> { Address.count }, 1 do
      post update_address_order_path(@order), params: { address: { address_line: 'Address Line',
                                                                   street: 'Street' ,
                                                                   city: 'City',
                                                                   postal_code: 'Postal Code' } }, as: :json
      assert_response :success

      @order.reload
      assert_equal 'Address Line', @order.address.address_line
      assert_equal 'Street', @order.address.street
      assert_equal 'City', @order.address.city
      assert_equal 'Postal Code', @order.address.postal_code
    end
  end

  test '#update_address - cannot update address of not your order' do
    post update_address_order_path(orders(:customer_2_order_1)), params: { address: { address_line: 'Address Line' } }, as: :json

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
