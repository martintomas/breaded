# frozen_string_literal: true

require 'test_helper'

class  Availabilities::FirstSuitableTest < ActiveSupport::TestCase
  test '#initialize - time is optional' do
    frozen_time = Time.current
    travel_to frozen_time do
      first_suitable_time_service = Availabilities::FirstSuitable.new
      assert_equal (frozen_time + 1.day).to_i, first_suitable_time_service.time.to_i
    end
  end

  test '#initialize - sets up correctly time at future' do
    future_time = 1.day.from_now
    first_suitable_time_service = Availabilities::FirstSuitable.new time: future_time
    assert_equal future_time, first_suitable_time_service.time
  end

  test '#initialize - time is past' do
    frozen_time = Time.current
    travel_to frozen_time do
      first_suitable_time_service = Availabilities::FirstSuitable.new time: 1.day.ago
      assert_equal (frozen_time + 1.day).to_i, first_suitable_time_service.time.to_i
    end
  end

  test '#find - closest time for monday when current time is at past' do
    travel_to Time.zone.parse('1st Oct 2020 04:00:00') do
      time_from, time_to = Availabilities::FirstSuitable.new(time: Time.zone.parse('19th Oct 2020 04:00:00')).find
      assert_equal Time.zone.parse('19th Oct 2020 10:00:00'), time_from
      assert_equal Time.zone.parse('19th Oct 2020 14:00:00'), time_to
    end
  end

  test '#find - closest time for monday when you request delivery at unusual time' do
    travel_to Time.zone.parse('1st Oct 2020 04:00:00') do
      time_from, time_to = Availabilities::FirstSuitable.new(time: Time.zone.parse('19th Oct 2020 15:00:00')).find
      assert_equal Time.zone.parse('19th Oct 2020 10:00:00'), time_from
      assert_equal Time.zone.parse('19th Oct 2020 14:00:00'), time_to
    end
  end

  test '#find - closest time for monday when it is already monday' do
    travel_to Time.zone.parse('19th Oct 2020 04:00:00') do
      time_from, time_to = Availabilities::FirstSuitable.new(time: Time.zone.parse('19th Oct 2020 04:00:00')).find
      assert_equal Time.zone.parse('20th Oct 2020 08:00:00'), time_from
      assert_equal Time.zone.parse('20th Oct 2020 10:00:00'), time_to
    end
  end

  test '#find - closest time for monday when when you request afternoon delivery' do
    travel_to Time.zone.parse('19th Oct 2020 04:00:00') do
      time_from, time_to = Availabilities::FirstSuitable.new(time: Time.zone.parse('19th Oct 2020 10:00:00')).find
      assert_equal Time.zone.parse('20th Oct 2020 10:00:00'), time_from
      assert_equal Time.zone.parse('20th Oct 2020 14:00:00'), time_to
    end
  end

  test '#find - closest time for tuesday when it is already tuesday' do
    travel_to Time.zone.parse('20th Oct 2020 04:00:00') do
      time_from, time_to = Availabilities::FirstSuitable.new(time: Time.zone.parse('20th Oct 2020 04:00:00')).find
      assert_equal Time.zone.parse('26th Oct 2020 10:00:00'), time_from
      assert_equal Time.zone.parse('26th Oct 2020 14:00:00'), time_to
    end
  end

  test '#find - assert raise when no availabilities exists' do
    Availability.delete_all
    assert_raise(Availabilities::FirstSuitable::MissingAvailabilitiesException) do
      Availabilities::FirstSuitable.new(time: Time.zone.parse('20th Oct 2020 04:00:00')).find
    end
  end
end
