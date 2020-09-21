# frozen_string_literal: true

require 'test_helper'

class TagTypeTest < ActiveSupport::TestCase
  setup do
    @full_content = { code: 'taste' }
  end

  test 'the validity - empty is not valid' do
    model = TagType.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = TagType.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without code is not valid' do
    invalid_with_missing TagType, :code
  end

  test 'the validity - code needs to be uniq' do
    already_taken_unique TagType, :code
  end
end
