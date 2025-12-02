# frozen_string_literal: true

module Requests
  module Payloads
    module Peruri
      class UpdateSn < HttpRequest
        def initialize(params = {})
          @serial_number  = params[:serial_number]
          @namadoc        = params[:namadoc]
          @nodoc          = params[:nodoc]
          @access_token   = params[:access_token]
          @namafile       = params[:namafile]
        end

        def send
          RestClient::Request.execute(
            method: :post,
            url: "#{ENV['PERURI_STAMP_BASE_URL']}/stamping/update-data/#{@serial_number}",
            payload: params,
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

          def params
            {
              nodoc: @nodoc,
              namadoc: @namadoc,
              namafile: @namafile
            }.to_json
          end
      end
    end
  end
end
