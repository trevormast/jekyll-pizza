require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { size: 1, url: REDISTOGO_URL }
end

Sidekiq.configure_server do |config|
  config.redis = { size: 9, url: REDISTOGO_URL }
end
