# frozen_string_literal: true

require 'test_helper'

class CurrencyTest < ActiveSupport::TestCase
  setup do
    @full_content = { code: 'czk',
                      symbol: 'Kč' }
  end

  test 'the validity - empty is not valid' do
    model = Currency.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = Currency.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without code is not valid' do
    invalid_with_missing Currency, :code
  end

  test 'the validity - without symbol is not valid' do
    invalid_with_missing Currency, :symbol
  end

  test 'the validity - code needs to be uniq' do
    already_taken_unique Currency, :code
  end
end
