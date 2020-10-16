# frozen_string_literal: true

require 'test_helper'

class Admin::OrdersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @order = orders :customer_order_1
  end

  test '#index' do
    get admin_orders_url

    assert_response :success
  end

  test '#show' do
    get admin_order_url(@order)

    assert_response :success
  end

  test '#edit' do
    get edit_admin_order_url(@order)

    assert_response :success
  end

  test '#update' do
    frozen_time = Time.current
    patch admin_order_url(@order), params: { order: { user_id: users(:customer).id,
                                                      subscription_id: subscriptions(:surprise_me_subscription).id,
                                                      delivery_date: frozen_time,
                                                      address_attributes: { address_line: 'address line',
                                                                            street: 'street',
                                                                            city: 'city',
                                                                            postal_code: '123456',
                                                                            state: 'CZ' } } }

    @order.reload
    assert_equal @order.user, users(:customer)
    assert_equal @order.subscription, subscriptions(:surprise_me_subscription)
    assert_equal @order.delivery_date.to_i, frozen_time.to_i
    assert_equal @order.address.address_line, 'address line'
    assert_equal @order.address.street, 'street'
    assert_equal @order.address.city, 'city'
    assert_equal @order.address.postal_code, '123456'
    assert_equal @order.address.state, 'CZ'
    assert_redirected_to admin_order_url(@order)
  end

  test '#destroy' do
    assert_difference 'Order.count', -1 do
      delete admin_order_url(@order)

      assert_redirected_to admin_orders_url
    end
  end
end
