# frozen_string_literal: true

module Requests
  module Payloads
    module Ai
      module DocumentExtractor
        class JobDetail < HttpRequest
          attr_reader :job_id

          def initialize(job_id)
            @job_id = job_id
          end

          def send
            RestClient.get "#{extractor_url}/status/#{job_id}", headers
          end

          private

            def extractor_url
              Config.find_by(key: Config::KEY_EXTRACTOR_HOST)&.value || 'http://ml-ali-dev.data.mekari.com:80/api/v1/esign-document-context-extractor'
            end
        end
      end
    end
  end
end
