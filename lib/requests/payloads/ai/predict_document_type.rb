# frozen_string_literal: true

module Requests
  module Payloads
    module Ai
      class PredictDocumentType < HttpRequest
        def initialize(file_path)
          @file_path = file_path
        end

        def send
          RestClient::Request.execute(
            method: :post,
            url: url,
            payload: payload,
            headers: headers_request,
            timeout: timeout.to_i,
            open_timeout: open_timeout.to_i
          )
        rescue RestClient::Exception => e
          Log.error('PredictDocumentType API call failed',
                    { status: e.http_code, body: e.response&.body })
          raise
        end

        private

          def headers_request
            headers.merge({
                            'User-Agent': 'eSign rest-client',
                            content_type: :multipart
                          })
          end

          def payload
            {
              file: File.new(@file_path)
            }
          end

          def url
            Config.find_by(key: Config::KEY_PREDICTION_URL)&.value ||
              'http://a19167adb59c64e278d6a94331ffb588-201640953.ap-southeast-3.elb.amazonaws.com:80/auto-tagging/api/v1/auto-tagging/predict'
          end

          def timeout
            Config.find_by(key: Config::KEY_PREDICTION_TIMEOUT)&.value || 7
          end

          def open_timeout
            Config.find_by(key: Config::KEY_PREDICTION_OPEN_TIMEOUT)&.value || 5
          end
      end
    end
  end
end
