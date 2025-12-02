# frozen_string_literal: true

module Requests
  module Payloads
    module GoogleApis
      class TokenInfo < HttpRequest
        def initialize(access_token)
          @access_token = access_token
        end

        def send
          RestClient.get(
            url
          )
        end

        private

          def url
            "https://oauth2.googleapis.com/tokeninfo?access_token=#{@access_token}"
          end
      end
    end
  end
end
