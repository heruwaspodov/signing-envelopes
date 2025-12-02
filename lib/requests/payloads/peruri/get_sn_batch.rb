# frozen_string_literal: true

module Requests
  module Payloads
    module Peruri
      class GetSnBatch < HttpRequest
        def initialize(params)
          @batch_id     = params[:batch_id]
          @proc_id      = params[:proc_id]
          @access_token = params[:access_token]
        end

        def send
          # the proc id string should be encoded
          escaped_proc_id = CGI.escape(@proc_id)

          RestClient.get(
            "#{ENV['PERURI_STAMP_BASE_URL']}/snqr?batchId=#{@batch_id}&procId=#{escaped_proc_id}",
            headers_request
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
