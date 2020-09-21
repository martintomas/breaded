# frozen_string_literal: true

namespace :db do
  desc 'Seeding database with demo data'
  task :demo_seed, [] => :environment do
    raise ActiveRecord::ProtectedEnvironmentError, Rails.env if Rails.env.production? && !ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK']

    puts 'SEEDING DEMO DATABASE'

    puts 'DEMO DATABASE HAS BEEN SEEDED'
  end
end
