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

  test '#available_at?' do
    availability = availabilities :availability_tuesday_1

    refute availability.available_at?(Time.zone.parse('19th Oct 2020 04:00:00'))
    refute availability.available_at?(Time.zone.parse('20th Oct 2020 04:00:00'))
    assert availability.available_at?(Time.zone.parse('20th Oct 2020 08:00:00'))
    refute availability.available_at?(Time.zone.parse('20th Oct 2020 10:00:00'))
  end

  test '.available_at?' do
    assert Availability.available_at?(Time.zone.parse('19th Oct 2020 10:00:00'))
    assert Availability.available_at?(Time.zone.parse('20th Oct 2020 08:00:00'))
    assert Availability.available_at?(Time.zone.parse('20th Oct 2020 10:00:00'))

    refute Availability.available_at?(Time.zone.parse('21th Oct 2020 10:00:00'))
    refute Availability.available_at?(Time.zone.parse('20th Oct 2020 14:00:00'))
    refute Availability.available_at?(Time.zone.parse('20th Oct 2020 4:00:00'))
  end
end
