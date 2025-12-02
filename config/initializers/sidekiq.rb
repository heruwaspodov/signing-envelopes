# frozen_string_literal: true

require 'datadog/statsd' # gem 'dogstatsd-ruby'

Sidekiq::Pro.dogstatsd = -> { Datadog::Statsd.new(ENV.fetch('DD_AGENT_HOST', 'localhost'), 8125, namespace: 'sidekiq') }

Sidekiq.configure_server do |config|
  url = ENV.fetch('SIDEKIQ_REDIS_URL') { ENV.fetch('REDIS_URL', nil) }
  config.logger.level = Rails.logger.level
  config.log_formatter = Sidekiq::Logger::Formatters::JSON.new
  config.redis = { url: url }

  config.server_middleware do |chain|
    require 'sidekiq/middleware/server/statsd'

    chain.add Sidekiq::Middleware::Server::Statsd

    chain.add SchedulerMiddleware
  end
end

Sidekiq.configure_client do |config|
  url = ENV.fetch('SIDEKIQ_REDIS_URL') { ENV.fetch('REDIS_URL', nil) }
  config.redis = { url: url }
end

# Sidekiq-cron
schedule_file = 'config/schedule.yml'
Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file) && Sidekiq.server?
