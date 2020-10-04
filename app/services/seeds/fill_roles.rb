# frozen_string_literal: true

class Seeds::FillRoles
  def self.perform_for(roles)
    roles.each do |role|
      next if Role.where(name: role).exists?

      puts "role: #{role}"
      Role.create! name: role
    end
  end
end
