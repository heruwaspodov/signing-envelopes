# frozen_string_literal: true

module Requests
  module Payloads
    module Qontak
      class RefreshToken < HttpRequest
        attr_reader :refresh_token

        def initialize(refresh_token)
          @refresh_token = refresh_token
        end

        def params
          {
            grant_type: 'refresh_token',
            refresh_token: @refresh_token
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
