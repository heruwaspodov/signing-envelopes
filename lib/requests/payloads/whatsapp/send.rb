# frozen_string_literal: true

module Requests
  module Payloads
    module Whatsapp
      class Send < HttpRequest
        attr_reader :broadcast

        EXECUTE_TYPE = 'immediately'

        def initialize(broadcast)
          @broadcast = broadcast
        end

        def params
          {
            to_number: @broadcast.to_number,
            to_name: @broadcast.to_name,
            message_template_id: @broadcast.message_template_id,
            channel_integration_id: @broadcast.channel_integration_id,
            language: {
              code: @broadcast.language_code
            },
            parameters: @broadcast.params,
            execute_type: EXECUTE_TYPE,
            send_at: DateTime.now
          }.to_json
        end

        def send
          p params
          RestClient.post "#{ENV['WA_URL']}/api/open/v1/broadcasts/whatsapp/direct", params,
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
