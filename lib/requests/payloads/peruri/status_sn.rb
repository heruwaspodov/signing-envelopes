# frozen_string_literal: true

module Requests
  module Payloads
    module Peruri
      class StatusSn < HttpRequest
        def initialize(params)
          @serial_number = params[:serial_number]
          @access_token = params[:access_token]
        end

        def send
          RestClient::Request.execute(
            method: :get,
            url: "#{ENV['PERURI_BASE_URL']}/api/chanel/stamp/ext?filter=#{@serial_number}",
            headers: headers_request,
            timeout: 60
          )
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
