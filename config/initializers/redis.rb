# frozen_string_literal: true

module FinanceMicromanager
  def self.redis
    @redis ||= ConnectionPool::Wrapper.new do
      redis_password = Rails.application.credentials.config.dig(:redis, :password)
      Redis.new(Rails.application.config.redis.merge(password: redis_password))
    end
  end
end
