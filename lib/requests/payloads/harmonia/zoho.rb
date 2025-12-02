# frozen_string_literal: true

module Requests
  module Payloads
    module Harmonia
      class Zoho < HttpRequest
        MAX_RETRY = 3
        BASE_DELAY = 1
        MAX_DELAY = 3

        def initialize(bearer_token, params)
          @bearer_token = bearer_token
          allowed_params.each do |param|
            next unless params[param.to_sym].present?

            instance_variable_set("@#{param}", params[param.to_sym])
          end
        end

        def send
          send_with_retry
          # RestClient.post(url, payload, headers_request)
        end

        def send_with_retry
          attempt = 0
          begin
            attempt += 1
            RestClient.post(url, payload, headers_request)
          rescue RestClient::BadRequest, RestClient::Unauthorized, RestClient::Forbidden => e
            notify_error(e&.message)
          rescue RestClient::InternalServerError, RestClient::BadGateway,
                 RestClient::ServiceUnavailable, RestClient::RequestTimeout => e
            if attempt < MAX_RETRY
              sleep calculate_delay(attempt)
              retry
            end
            notify_error(e&.response)
          end
        end

        private

          def allowed_params
            %w[sso_company_id event_remark record_action module cid pic_department industry
               used_esignature_before employee_size_category lead_status
               stage initial_needs billing]
          end

          def url
            "#{ENV.fetch('HARMONIA_API_BASE_URL', nil)}/v1/zoho/request"
          end

          def headers_request
            headers.merge({
                            authorization: "Bearer #{@bearer_token}"
                          })
          end

          def payload
            {
              sso_company_id: @sso_company_id,
              event_remark: @event_remark,
              record_action: @record_action,
              modules: [
                {
                  module: @module,
                  data: {
                    Company_ID: @cid,
                    PIC_Department: @pic_department,
                    Industry: @industry,
                    Used_esignature_before: @used_esignature_before,
                    Employee_Size_Category: Company::EMPLOYEE_SIZE_MAP[@employee_size_category],
                    Lead_Status: @lead_status,
                    Stage: @stage,
                    billing: @billing
                  }
                }
              ]
            }
          end

          def calculate_delay(attempt)
            # Menghitung delay eksponensial, tetapi tidak melebihi MAX_DELAY
            [BASE_DELAY * (2**(attempt - 1)), MAX_DELAY].min
          end

          def notify_error(error_message)
            Alert::NotifyErrorAlertJob.perform_later 'Failed: Send Harmonia Zoho Request' \
                                                     "\nwith message: #{error_message}"
          end
      end
    end
  end
end
