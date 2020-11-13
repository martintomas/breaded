# frozen_string_literal: true

require 'test_helper'

class AddressesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users :customer
    @address = addresses :customer_address
    sign_in @user
  end

  test '#index' do
    get addresses_path

    assert_response :success
  end

  test '#new' do
    get new_address_path

    assert_response :success
  end

  test '#create' do
    assert_difference -> { Address.count }, 1 do
      post addresses_path, params: { address: { address_type_id: address_types(:personal).id,
                                                address_line: 'Address Line',
                                                street: 'Street',
                                                city: 'City',
                                                postal_code: 'Postal Code' } }
      address = Address.last
      assert_equal address_types(:personal), address.address_type
      assert_equal 'Address Line', address.address_line
      assert_equal 'Street', address.street
      assert_equal 'City', address.city
      assert_equal 'Postal Code', address.postal_code
      refute address.main?
    end
  end

  test '#create - when user does not have any address yet' do
    @user.addresses.destroy_all
    assert_difference -> { Address.count }, 1 do
      post addresses_path, params: { address: { address_type_id: address_types(:personal).id,
                                                address_line: 'Address Line',
                                                street: 'Street',
                                                city: 'City',
                                                postal_code: 'Postal Code' } }

      assert_redirected_to addresses_path

      address = Address.last
      assert address.main?
    end
  end

  test '#edit' do
    get edit_address_path(@address)

    assert_response :success
  end

  test '#edit - cannot see address of different user' do
    get edit_address_path(addresses(:admin_address))

    assert_redirected_to root_url
  end

  test '#update' do
    assert_no_difference -> { Address.count } do
      patch address_path(@address), params: { address: { address_type_id: address_types(:personal).id,
                                                         address_line: 'Address Line',
                                                         street: 'Street',
                                                         city: 'City',
                                                         postal_code: 'Postal Code' } }
      assert_redirected_to addresses_path

      @address.reload
      assert_equal address_types(:personal), @address.address_type
      assert_equal 'Address Line', @address.address_line
      assert_equal 'Street', @address.street
      assert_equal 'City', @address.city
      assert_equal 'Postal Code', @address.postal_code
    end
  end

  test '#update - cannot update address of different person' do
    patch address_path(addresses(:admin_address)), params: { address: { street: 'Street' } }

    assert_redirected_to root_url
  end

  test '#destroy' do
    assert_difference -> { Address.count }, -1 do
      delete address_path(@address)

      assert_redirected_to addresses_path
    end
  end

  test '#destroy - cannot delete address of different person' do
    assert_no_difference -> { Address.count } do
      delete address_path(addresses(:admin_address))

      assert_redirected_to root_url
    end
  end

  test '#set_as_main' do
    new_main_address = addresses :customer_address_1
    get set_as_main_address_path(new_main_address)

    assert_redirected_to addresses_path
    assert new_main_address.reload.main?
    refute @address.reload.main?
  end
end
