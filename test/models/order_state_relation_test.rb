require 'test_helper'

class OrderStateRelationTest < ActiveSupport::TestCase
  setup do
    @full_content = { order: orders(:customer_order_4),
                      order_state: order_states(:on_way) }
  end

  test 'the validity - empty is not valid' do
    model = OrderStateRelation.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = OrderStateRelation.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without order is not valid' do
    invalid_with_missing OrderStateRelation, :order
  end

  test 'the validity - without order_state is not valid' do
    invalid_with_missing OrderStateRelation, :order_state
  end

  test 'the validity - combination of language and localised_text has to be unique' do
    OrderStateRelation.create! @full_content
    refute OrderStateRelation.new(@full_content).valid?
  end
end
