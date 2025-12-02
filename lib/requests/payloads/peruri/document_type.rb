# frozen_string_literal: true

module Requests
  module Payloads
    module Peruri
      class DocumentType < HttpRequest
        def initialize; end

        def send
          RestClient.get "#{ENV['PERURI_STAMP_BASE_URL']}/jenisdoc", headers_request
        end

        private

          def access_token
            sender = Requests::Sender.new
            hit = sender >> Requests::Payloads::Peruri::Login.new

            return if hit['response']['statusCode'] != '00'

            hit['response']['token']
          end

          def headers_request
            headers.merge({
                            authorization: "Bearer #{access_token}",
                            'User-Agent': 'eSign rest-client'
                          })
          end
      end
    end
  end
end
