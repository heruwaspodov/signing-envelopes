# frozen_string_literal: true

module Requests
  module Payloads
    module Qontak
      class ContactSync < HttpRequest
        attr_reader :bearer_token, :user, :company

        def initialize(bearer_token, user, company)
          @bearer_token = bearer_token
          @user = user
          @company = company
        end

        def params
          {
            first_name: @user.full_name,
            last_name: '',
            job_title: @user.job_title,
            # creator_id: ,
            email: @user.email,
            telephone: @user.phone,
            crm_company_id: @company.crm_qontak_company_id
          }
        end

        def send
          RestClient.post "#{ENV['QONTAK_URL']}/api/v3.1/contacts", params, headers_request
        end

        def after_success(data)
          data
        end

        private

          def headers_request
            headers.merge({
                            content_type: 'application/json',
                            authorization: "Bearer #{@bearer_token}"
                          })
          end
      end
    end
  end
end
