Raven.configure do |config|
  config.environments = %w(production)
  config.dsn = Rails.application.credentials.sentry[:token]
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
