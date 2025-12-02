# frozen_string_literal: true

module Requests
  module Payloads
    module Qontak
      class CompanyInfo < HttpRequest
        attr_reader :bearer_token

        def initialize(bearer_token)
          @bearer_token = bearer_token
        end

        def send
          RestClient.get "#{ENV['QONTAK_URL']}/api/v3.1/companies/info", headers_request
        end

        def after_success(data)
          data
        end

        private

          def headers_request
            headers.merge({
                            content_type: 'application/json',
                            authorization: "Bearer #{@bearer_token}"
                          })
          end
      end
    end
  end
end
