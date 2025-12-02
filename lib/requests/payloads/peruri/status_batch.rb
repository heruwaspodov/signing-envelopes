# frozen_string_literal: true

module Requests
  module Payloads
    module Peruri
      class StatusBatch < HttpRequest
        def initialize(params)
          @batch_id     = params[:batch_id]
          @access_token = params[:access_token]
        end

        def send
          RestClient::Request.execute(
            method: :get,
            url: "#{ENV['PERURI_STAMP_BASE_URL']}/snqr/status-batch?batchId=#{@batch_id}",
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
