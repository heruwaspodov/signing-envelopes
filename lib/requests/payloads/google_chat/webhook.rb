# frozen_string_literal: true

module Requests
  module Payloads
    module GoogleChat
      class Webhook < HttpRequest
        def initialize(url, message)
          @url = url
          @message = message
        end

        def send
          RestClient.post(
            @url,
            params.to_json,
            headers_request
          )
        end

        private

          def headers_request
            headers.merge({ 'Content-Type' => 'application/json' })
          end

          # https://developers.google.com/chat/api/guides/message-formats/text
          def params
            {
              text: @message
            }
          end
      end
    end
  end
end
