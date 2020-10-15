require 'test_helper'

class OrderStateTest < ActiveSupport::TestCase
  setup do
    @full_content = { code: 'code' }
  end

  test 'the validity - empty is not valid' do
    model = OrderState.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = OrderState.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without code is not valid' do
    invalid_with_missing OrderState, :code
  end

  test 'the validity - code needs to be uniq' do
    already_taken_unique OrderState, :code
  end
end
