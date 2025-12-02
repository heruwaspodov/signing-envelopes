# frozen_string_literal: true

module Requests
  module Payloads
    class Sso < HttpRequest
      def initialize; end

      def send
        RestClient.get 'https://httpbin.org/get', {}
      end
    end
  end
end
