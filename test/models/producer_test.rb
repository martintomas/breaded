# frozen_string_literal: true

require 'test_helper'

class ProducerTest < ActiveSupport::TestCase
  setup do
    @full_content = { name: localised_texts(:bread_and_butter_name),
                      description: localised_texts(:bread_and_butter_description) }
  end

  test 'the validity - empty is not valid' do
    model = Producer.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = Producer.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without name is not valid' do
    invalid_with_missing Producer, :name
  end

  test 'the validity - without description is not valid' do
    invalid_with_missing Producer, :description
  end
end
