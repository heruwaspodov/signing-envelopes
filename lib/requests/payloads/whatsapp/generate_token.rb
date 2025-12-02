# frozen_string_literal: true

module Requests
  module Payloads
    module Whatsapp
      class GenerateToken < HttpRequest
        def initialize; end

        def send
          RestClient.post "#{ENV['WA_URL']}/oauth/token", params
        end

        def after_success(data)
          save_to_db(data)
          store_to_redis(data)
          data['access_token']
        end

        def save_to_db(data)
          config = Config.where(key: Config::KEY_WA_BEARER_TOKEN).first_or_initialize
          config.value = data
          config.save
          config
        end

        def store_to_redis(data)
          redis = RedisLib::RedisInstance.new
          redis.set_redis(Config::KEY_WA_BEARER_TOKEN, data['access_token'])
          redis.expire_redis(Config::KEY_WA_BEARER_TOKEN, data['expires_in'])
        end

        private

          def params
            {
              username: ENV['WA_USERNAME'],
              password: ENV['WA_PASSWORD'],
              grant_type: 'password',
              client_id: ENV['WA_CLIENT_ID'],
              client_secret: ENV['WA_CLIENT_SECRET']
            }
          end

          def headers_request
            headers.merge({
                            content_type: 'application/x-www-form-urlencoded'
                          })
          end
      end
    end
  end
end
