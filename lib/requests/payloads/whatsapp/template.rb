# frozen_string_literal: true

module Requests
  module Payloads
    module Whatsapp
      class Template < HttpRequest
        attr_reader :template_id

        def initialize(template_id)
          @template_id = template_id
        end

        def send
          RestClient.get "#{ENV['WA_URL']}/api/open/v1/templates/#{@template_id}/whatsapp",
                         headers_request
        end

        def access_token
          ::Whatsapp::Authenticate.new.call
        end

        def headers_request
          headers.merge({
                          authorization: "Bearer #{access_token}"
                        })
        end
      end
    end
  end
end
