# frozen_string_literal: true

require 'flipper/adapters/redis'

Flipper.configure do |config|
  config.default do
    url = ENV.fetch('FLIPPER_REDIS_URL') { ENV.fetch('REDIS_URL', nil) }
    db ||= ENV.fetch('TEST_ENV_NUMBER', nil) if Rails.env.test?
    client = Redis.new(url: url, db: db)
    adapter = Flipper::Adapters::Redis.new(client)
    Flipper.new(adapter)
  end
end
