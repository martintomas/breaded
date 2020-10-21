require 'test_helper'

class OrderSurpriseTest < ActiveSupport::TestCase
  setup do
    @full_content = { order: orders(:surprise_order),
                      amount: 10,
                      tag: tags(:butter_tag) }
  end

  test 'the validity - empty is not valid' do
    model = OrderSurprise.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = OrderSurprise.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without order is not valid' do
    invalid_with_missing OrderSurprise, :order
  end

  test 'the validity - without tag is not valid' do
    invalid_with_missing OrderSurprise, :tag
  end

  test 'the validity - without amount is valid' do
    model = OrderSurprise.new @full_content.except(:amount)
    assert model.valid?, model.errors.full_messages
    assert_nil model.amount
  end
end
