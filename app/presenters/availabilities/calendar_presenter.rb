# frozen_string_literal: true

class Availabilities::CalendarPresenter
  attr_accessor :to_time

  def initialize(to_time: 1.month.from_now)
    @to_time = to_time
  end

  def start_date
    calendar_data.keys.min.strftime('%e.%B')
  end

  def end_date
    calendar_data.keys.max.strftime('%e.%B')
  end

  def times_grouped_by_days
    calendar_data.group_by do |key, _|
      key.to_date
    end
  end

  private

  def calendar_data
    @calendar_data ||= find_suitable_days_from Time.current
  end

  def find_suitable_days_from(from_time)
    (1..((to_time - from_time) / 1.day).ceil).each_with_object({}) do |i, result|
      day_in_week = ((from_time.wday + i - 1) % 7) + 1
      Array.wrap(availabilities[day_in_week]).each do |availability|
        time_from = (from_time + i.days).change(hour: availability.time_from.utc.hour, min:  availability.time_from.utc.min, sec: 0)
        time_to = (from_time + i.days).change(hour: availability.time_to.utc.hour, min:  availability.time_to.utc.min, sec: 0)
        result[time_from] = [time_from, time_to]
      end
    end
  end

  def availabilities
    @availabilities ||= Availability.all.group_by(&:day_in_week)
  end
end