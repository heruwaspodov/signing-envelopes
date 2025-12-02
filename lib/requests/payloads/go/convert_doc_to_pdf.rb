# frozen_string_literal: true

module Requests
  module Payloads
    module Go
      class ConvertDocToPdf < HttpRequest
        def initialize(file_path)
          @file_path = file_path
        end

        def params
          {
            file_path: @file_path
          }.to_json
        end

        def send
          RestClient.post "#{ENV['GO_BASE_URL']}/convert", params, headers
        end
      end
    end
  end
end
