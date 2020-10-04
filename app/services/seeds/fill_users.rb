# frozen_string_literal: true

class Seeds::FillUsers
  def self.perform_for(users)
    users.each do |user|
      next if User.where(email: user[:email]).exists?

      puts "user: #{user[:email]}"
      user[:role_ids] = Role.where(name: user.delete(:roles)).pluck(:id)
      User.create! user.merge(confirmed_at: Time.current)
    end
  end
end
