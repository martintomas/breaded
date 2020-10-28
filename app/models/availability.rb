# frozen_string_literal: true

class Availability < ApplicationRecord
  validates :day_in_week, :time_from, :time_to, presence: true

  def available_at?(datetime)
    datetime.wday == day_in_week &&
      time_from.utc.strftime('%H%M') <= datetime.strftime('%H%M') &&
      time_to.utc.strftime('%H%M') > datetime.strftime('%H%M')
  end

  def self.available_at?(datetime)
    Availability.where(day_in_week: datetime.wday).any? { |availability| availability.available_at? datetime }
  end
end
