# frozen_string_literal: true

module Requests
  module Payloads
    module Ai
      module DocumentExtractor
        class Extract < HttpRequest
          attr_reader :payload

          def initialize(payload)
            @payload = payload
          end

          def send
            RestClient.post url, payload.to_json, headers
          end

          private

            def url
              "#{extractor_url}/extract"
            end

            def extractor_url
              Config.find_by(key: Config::KEY_EXTRACTOR_HOST)&.value || 'http://ml-ali-dev.data.mekari.com:80/api/v1/esign-document-context-extractor'
            end
        end
      end
    end
  end
end
