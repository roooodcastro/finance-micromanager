# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  config.redis = Rails.configuration.redis.deep_symbolize_keys.except(:reconnect_delay, :reconnect_delay_max)

  SidekiqScheduler::Scheduler.enabled = true
end

Sidekiq.configure_client do |config|
  config.redis = Rails.configuration.redis.deep_symbolize_keys.except(:reconnect_delay, :reconnect_delay_max)
end
