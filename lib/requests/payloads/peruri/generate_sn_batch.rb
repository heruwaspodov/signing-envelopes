# frozen_string_literal: true

module Requests
  module Payloads
    module Peruri
      class GenerateSnBatch < HttpRequest
        attr_accessor :return_url,
                      :tipe,
                      :partial,
                      :document,
                      :access_token

        def initialize(params = {})
          @return_url   = params[:return_url]
          @tipe         = params[:tipe]
          @partial      = params[:partial]
          @document     = params[:document]
          @access_token = params[:access_token]
        end

        def send
          RestClient.post "#{ENV['PERURI_BATCH_SN_BASE_URL']}/api/v2/serialnumber/batch",
                          params,
                          headers_request
        end

        private

          def headers_request
            headers.merge({
                            authorization: "Bearer #{@access_token}",
                            'User-Agent': 'eSign rest-client'
                          })
          end

          def params
            {
              return_url: @return_url,
              tipe: @tipe,
              partial: @partial,
              document: @document
            }.to_json
          end
      end
    end
  end
end
