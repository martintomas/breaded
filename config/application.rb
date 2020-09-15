require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Breaded
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.active_job.queue_adapter = :sidekiq
    config.i18n.default_locale = :en
    config.load_defaults 6.0

    config.filter_parameters << :password
    config.time_zone = 'London'
  end
end
