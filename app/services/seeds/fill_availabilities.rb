# frozen_string_literal: true

class Seeds::FillAvailabilities
  def self.perform_for(availabilities)
    availabilities.each do |availability|
      next if Availability.where(availability).exists?

      puts "availability: #{availability[:day_in_week]}: #{availability[:time_from]}-#{availability[:time_to]}"
      Availability.create! availability
    end
  end
end
