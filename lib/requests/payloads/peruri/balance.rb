# frozen_string_literal: true

module Requests
  module Payloads
    module Peruri
      class Balance < HttpRequest
        def initialize(access_token)
          @access_token = access_token
        end

        def send
          RestClient.get "#{ENV['PERURI_BASE_URL']}/function/saldopos", headers_request
        end

        private

          def headers_request
            headers.merge({
                            authorization: "Bearer #{@access_token}",
                            'User-Agent': 'eSign rest-client'
                          })
          end
      end
    end
  end
end
