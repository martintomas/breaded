# frozen_string_literal: true

require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  setup do
    @full_content = { addressable: users(:customer),
                      address_type: address_types(:personal),
                      address_line: 'Address Line',
                      street: 'Street 1',
                      postal_code: '54546',
                      city: 'London',
                      state: 'UK',
                      main: false }
    @address = addresses :customer_address
  end

  test 'the validity - empty is not valid' do
    model = Address.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = Address.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without addressable is not valid' do
    invalid_with_missing Address,:addressable
  end

  test 'the validity - without address_type is valid' do
    model = Address.new @full_content.except(:address_type)
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without address_line is valid' do
    model = Address.new @full_content.except(:address_line)
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without street is not valid' do
    invalid_with_missing Address,:street
  end

  test 'the validity - without postal_code is not valid' do
    invalid_with_missing Address,:postal_code
  end

  test 'the validity - without city is not valid' do
    invalid_with_missing Address,:city
  end

  test 'the validity - without state is valid' do
    model = Address.new @full_content.except(:state)
    assert model.valid?, model.errors.full_messages
    assert_equal 'UK', model.state
  end

  test 'the validity - without main is valid' do
    model = Address.new @full_content.except(:main)
    assert model.valid?, model.errors.full_messages
    refute model.main
  end

  test 'to_s' do
    assert_equal "#{@address.address_line}, #{@address.street} #{@address.city} - #{@address.postal_code}", @address.to_s
  end
end
