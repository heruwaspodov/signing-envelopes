# frozen_string_literal: true

module Requests
  module Payloads
    module Qontak
      class GenerateToken < HttpRequest
        def initialize; end

        def params
          {
            grant_type: 'password',
            username: ENV['QONTAK_OAUTH_USERNAME'],
            password: ENV['QONTAK_OAUTH_PASSWORD']
          }
        end

        def send
          RestClient.post "#{ENV['QONTAK_URL']}/oauth/token", params, headers_request
        end

        def after_success(data)
          save_to_config(data)
        end

        def save_to_config(data)
          config = Config.where(key: Config::KEY_QONTAK_BEARER_TOKEN).first_or_initialize
          config.value = data
          config.save
          config
        end

        private

          def headers_request
            headers.merge({
                            content_type: 'application/x-www-form-urlencoded'
                          })
          end
      end
    end
  end
end
