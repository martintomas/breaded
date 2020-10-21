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

  test 'the validity - without address_type is not valid' do
    invalid_with_missing Address,:address_type
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

  test 'the validity - without state is not valid' do
    invalid_with_missing Address,:state
  end

  test 'the validity - without main is valid' do
    model = Address.new @full_content.except(:main)
    assert model.valid?, model.errors.full_messages
    refute model.main
  end
end
