# frozen_string_literal: true

class Availability < ApplicationRecord
  validates :day_in_week, :time_from, :time_to, presence: true
end
