Sidekiq.configure_server do |config|
  config.redis = { url: Rails.application.credentials.redis.try(:[], :url),
                   password: Rails.application.credentials.redis.try(:[], :password)}
end
Sidekiq.configure_client do |config|
  config.redis = { url: Rails.application.credentials.redis.try(:[], :url),
                   password: Rails.application.credentials.redis.try(:[], :password)}
end
