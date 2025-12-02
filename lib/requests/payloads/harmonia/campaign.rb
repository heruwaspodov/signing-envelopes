# frozen_string_literal: true

module Requests
  module Payloads
    module Harmonia
      class Campaign < HttpRequest
        def initialize(bearer_token, params)
          @bearer_token = bearer_token
          allowed_params.each do |param|
            next unless params[param.to_sym].present?

            instance_variable_set("@#{param}", params[param.to_sym])
          end
        end

        def send
          RestClient.post url, payload, headers_request
        end

        private

          def allowed_params
            %w[sso_company_id campaign_type product gclid utm_source utm_medium utm_campaign
               mkt_device_type cookie_id]
          end

          def url
            "#{ENV.fetch('HARMONIA_API_BASE_URL', nil)}/v1/campaign"
          end

          def headers_request
            headers.merge({
                            content_type: 'application/json',
                            authorization: "Bearer #{@bearer_token}"
                          })
          end

          def payload
            {
              sso_company_id: @sso_company_id,
              campaign_type: @campaign_type,
              product: @product,
              gclid: @gclid,
              utm_source: @utm_source,
              utm_medium: @utm_medium,
              utm_campaign: @utm_campaign,
              mkt_device_type: @mkt_device_type,
              cookie_id: @cookie_id
            }
          end
      end
    end
  end
end
