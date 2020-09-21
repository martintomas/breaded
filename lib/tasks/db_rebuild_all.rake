# frozen_string_literal: true

namespace :db do
  desc 'Rebuild database'
  task :rebuild, [] => :environment do
    raise ActiveRecord::ProtectedEnvironmentError.new(Rails.env) if Rails.env.production? && !ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK']

    Rake::Task['db:drop'].execute
    Rake::Task['db:create'].execute
    Rake::Task['db:migrate'].execute
    Rake::Task['db:seed'].execute
  end
end
