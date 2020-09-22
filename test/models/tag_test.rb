# frozen_string_literal: true

require 'test_helper'

class TagTest < ActiveSupport::TestCase
  setup do
    @full_content = { name: localised_texts(:vegetarian_localized_text),
                      tag_type: tag_types(:attribute) }
  end

  test 'the validity - empty is not valid' do
    model = Tag.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = Tag.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without name is not valid' do
    invalid_with_missing Tag, :name
  end

  test 'the validity - without tag_type is not valid' do
    invalid_with_missing Tag, :tag_type
  end
end