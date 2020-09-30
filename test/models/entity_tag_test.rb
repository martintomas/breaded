# frozen_string_literal: true

require 'test_helper'

class EntityTagTest < ActiveSupport::TestCase
  setup do
    @full_content = { entity: foods(:seeded_bread),
                      tag: tags(:vegetarian_tag) }
  end

  test 'the validity - empty is not valid' do
    model = EntityTag.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = EntityTag.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without food is not valid' do
    invalid_with_missing EntityTag, :entity
  end

  test 'the validity - without tag is not valid' do
    invalid_with_missing EntityTag, :tag
  end

  test 'the validity - combination of food and tag has to be unique' do
    EntityTag.create! @full_content
    refute EntityTag.new(@full_content).valid?
  end
end
