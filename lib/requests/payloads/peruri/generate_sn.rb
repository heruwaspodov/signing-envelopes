# frozen_string_literal: true

module Requests
  module Payloads
    module Peruri
      class GenerateSn < HttpRequest
        attr_accessor :document_type, :filename, :document_value,
                      :sn_only, :document_number, :created_at, :access_token

        def initialize(params)
          @document_type    = params[:document_type]
          @filename         = params[:filename]
          @document_value   = params[:document_value]
          @sn_only          = params[:sn_only]
          @document_number  = params[:document_number]
          @created_at       = params[:created_at]
          @access_token     = params[:access_token]
        end

        def send
          RestClient.post(
            "#{ENV['PERURI_STAMP_BASE_URL']}/chanel/stampv2",
            params,
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

          def params
            {
              namadoc: @document_type,
              namafile: @filename,
              nilaidoc: @document_value,
              snOnly: @sn_only,
              nodoc: @document_number,
              tgldoc: @created_at
            }
          end
      end
    end
  end
end
