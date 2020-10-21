# frozen_string_literal: true

require 'test_helper'

class AvailabilityTest < ActiveSupport::TestCase
  setup do
    @full_content = { day_in_week: 1,
                      time_from: Time.current,
                      time_to: Time.current + 4.hours }
  end

  test 'the validity - empty is not valid' do
    model = Availability.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = Availability.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without day_in_week is not valid' do
    invalid_with_missing Availability, :day_in_week
  end

  test 'the validity - without time_from is not valid' do
    invalid_with_missing Availability, :time_from
  end

  test 'the validity - without time_to is not valid' do
    invalid_with_missing Availability, :time_to
  end
end
