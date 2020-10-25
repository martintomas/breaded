# frozen_string_literal: true

class Availabilities::FirstSuitable
  attr_accessor :time

  class MissingAvailabilitiesException < StandardError; end

  def initialize(time: Time.current)
    @time = skip_past_date_for time
  end

  def find
    availabilities, wday_diff = find_availabilities
    availability = closest_one_from availabilities
    updated_time = time + wday_diff.days

    [updated_time.change(hour: availability.time_from.utc.hour, min:  availability.time_from.utc.min, sec: 0),
     updated_time.change(hour: availability.time_to.utc.hour, min:  availability.time_to.utc.min, sec: 0)]
  end

  private

  def skip_past_date_for(time)
    return time if time.to_date > current_date

    time = time.change year: current_date.year, month: current_date.month, day: current_date.day
    time + 1.day
  end

  def current_date
    @current_date ||= Time.current.to_date
  end

  def find_availabilities
    (0..6).each do |i|
      day_in_week = time.wday + i
      day_in_week -= 7 if day_in_week > 7
      availabilities = Availability.where(day_in_week: day_in_week)
      return [availabilities, i] if availabilities.exists?
    end
    raise MissingAvailabilitiesException, 'missing availabilities!'
  end

  def closest_one_from(availabilities)
    availabilities.each do |availability|
      if availability.time_from.utc.strftime('%H%M') <= time.strftime('%H%M') &&
        availability.time_to.utc.strftime('%H%M') > time.strftime('%H%M')
        return availability
      end
    end
    availabilities.first
  end
end
