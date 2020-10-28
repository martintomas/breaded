# frozen_string_literal: true

require 'test_helper'

class Availabilities::CalendarPresenterTest < ActiveSupport::TestCase
  setup do
    @service = Availabilities::CalendarPresenter.new
  end

  test '#start_date' do
    travel_to Time.zone.parse('25th Oct 2020 04:00:00') do
      assert_equal '26.October', @service.start_date
    end
  end

  test '#start_date - current date is ignored' do
    travel_to Time.zone.parse('26th Oct 2020 04:00:00') do
      assert_equal '27.October', @service.start_date
    end
  end

  test '#end_date' do
    travel_to Time.zone.parse('25th Oct 2020 04:00:00') do
      assert_equal '24.November', @service.end_date
    end
  end

  test '#end_date - time period can be shortened' do
    travel_to Time.zone.parse('25th Oct 2020 04:00:00') do
      assert_equal '27.October', Availabilities::CalendarPresenter.new(to_time: 1.week.from_now).end_date
    end
  end

  test '#times_grouped_by_days' do
    travel_to Time.zone.parse('25th Oct 2020 04:00:00') do
      time_ranges = Availabilities::CalendarPresenter.new(to_time: 2.weeks.from_now).times_grouped_by_days

      assert_equal time_ranges, { Date.parse('26th Oct 2020') => [[Time.zone.parse('26th Oct 2020 10:00:00'),
                                                                  Time.zone.parse('26th Oct 2020 14:00:00')]],
                                  Date.parse('27th Oct 2020') => [[Time.zone.parse('27th Oct 2020 08:00:00'),
                                                                   Time.zone.parse('27th Oct 2020 10:00:00')],
                                                                  [Time.zone.parse('27th Oct 2020 10:00:00'),
                                                                   Time.zone.parse('27th Oct 2020 14:00:00')]],
                                  Date.parse('2nd Nov 2020') => [[Time.zone.parse('2nd Nov 2020 10:00:00'),
                                                                   Time.zone.parse('2nd Nov 2020 14:00:00')]],
                                  Date.parse('3nd Nov 2020') => [[Time.zone.parse('3nd Nov 2020 08:00:00'),
                                                                   Time.zone.parse('3nd Nov 2020 10:00:00')],
                                                                  [Time.zone.parse('3nd Nov 2020 10:00:00'),
                                                                   Time.zone.parse('3nd Nov 2020 14:00:00')]]}
    end
  end
end
