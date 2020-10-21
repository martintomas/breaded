# frozen_string_literal: true

class Availabilities::FirstSuitable
  attr_accessor :time

  def initialize(time: Time.current)
    @time = time
  end

  def find
    availabilities, wday_diff = find_availabilities
    availability = closest_one_from availabilities
    time += wday_diff.days

    [time.change(hour: availability.time_from.hour, min:  availability.time_from.min, sec: 0),
     time.change(hour: availability.time_to.hour, min:  availability.time_to.min, sec: 0)]
  end

  private

  def find_availabilities
    (0..6).each do |i|
      day_in_week = time.wday + i
      day_in_week -= 7 if day_in_week > 7
      availabilities = Availability.where(day_in_week: day_in_week)
      return [availabilities, i] if availabilities.exists?
    end
  end

  def closest_one_from(availabilities)
    availabilities.each do |availability|
      if availability.time_from.strftime('%H%M%S%N') >= time.strftime('%H%M%S%N') &&
        availability.time_to.strftime('%H%M%S%N') <= time.strftime('%H%M%S%N')
        return availability
      end
    end
    availabilities.first
  end
end
