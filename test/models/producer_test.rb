# frozen_string_literal: true

require 'test_helper'

class ProducerTest < ActiveSupport::TestCase
  setup do
    @full_content = { name: localised_texts(:bread_and_butter_name),
                      description: localised_texts(:bread_and_butter_description),
                      producer_application: producer_applications(:producer_application_bread_and_butter) }
    @producer = producers :bread_and_butter
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

  test 'the validity - without producer_application is valid' do
    model = Producer.new @full_content.except(:producer_application)
    assert model.valid?, model.errors.full_messages
  end

  test '#to_s' do
    assert_equal @producer.localized_name, @producer.to_s
  end
end
