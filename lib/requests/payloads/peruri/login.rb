# frozen_string_literal: true

module Requests
  module Payloads
    module Peruri
      class Login < HttpRequest
        def initialize; end

        def send
          RestClient::Request.execute(
            method: :post,
            url: "#{ENV['PERURI_BASE_URL']}/api/users/login",
            payload: params,
            headers: headers,
            timeout: 60
          )
        end

        private

          def headers
            {
              'User-Agent' => 'eSign rest-client'
            }
          end

          def params
            {
              user: ENV['PERURI_USERNAME'],
              password: ENV['PERURI_PASS']
            }
          end
      end
    end
  end
end
