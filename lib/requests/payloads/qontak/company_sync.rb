# frozen_string_literal: true

module Requests
  module Payloads
    module Qontak
      class CompanySync < HttpRequest
        attr_reader :bearer_token, :company, :fields

        def initialize(bearer_token, company)
          @company = company
          @bearer_token = bearer_token
          @fields = fields_company
        end

        def fields_company
          sender = Requests::Sender.new
          sender >> Requests::Payloads::Qontak::CompanyInfo.new(@bearer_token)
        end

        def data_company
          return nil unless company.present?

          {
            name: @company.name,
            city: @company.city_name,
            industry_id: industry_mapping(@fields, @company.industry_name),
            industry_name: @company.industry_name,
            number_of_employees: @company.employee_size,
            website: @company.website
          }
        end

        def data
          data_company.merge({
                               additional_fields: [{
                                 id: @fields['response'].find do |e|
                                       e['name'] == 'company_size'
                                     end ['id'],
                                 value: company_size_mapping(@fields, @company.employee_size.to_i)
                               }]
                             })
        end

        def send
          RestClient.post "#{ENV['QONTAK_URL']}/api/v3.1/companies", data.to_json, headers_request
        end

        def after_success(data)
          update_crm_qontak_company(data) unless @company.crm_qontak_company_id.present?
          data
        end

        private

          def update_crm_qontak_company(data)
            id = data.dig('response', 'id')

            if id.present?
              @company.crm_qontak_company_id = id
              @company.save
            end

            @company
          end

          def headers_request
            headers.merge({
                            content_type: 'application/json',
                            authorization: "Bearer #{@bearer_token}"
                          })
          end

          def industry_mapping(fields, industry_name)
            industries = fields['response'].find { |e| e['name'] == 'industry_id' }
            industries = industries['dropdown']
            industries.each_with_index do |val, _idx|
              return val['id'] if val['name'] == industry_name
            end
            nil
          end

          def company_size_mapping(fields, size)
            compsize = fields['response'].find { |e| e['name'] == 'company_size' }
            s = define_company_size(compsize)
            company_sizes = s.map { |e| [e.first.to_i, e.second.to_i] }

            company_size(compsize['dropdown'], size, company_sizes)
          end

          def define_company_size(compsize)
            compsize['dropdown'].map { |e| e['name'].gsub(/[^-0-9]/, '') }.map { |e| e.split('-') }
          end

          def company_size(sizes, size, company_sizes)
            arr = company_sizes.map { |e| e[0] }

            if size <= arr.min
              sizes[arr.index(arr.min)]['id']
            elsif size >= arr.max
              sizes[arr.index(arr.max)]['id']
            else
              mapping_size(sizes, size, arr, company_sizes)
            end
          end

          def mapping_size(sizes, size, arr, company_sizes)
            company_sizes.each_with_index do |val, index|
              return sizes[index]['id'] if val[0] != arr.min && val[0] != arr.max && size >= val[0] && size <= val[1]
            end
          end
      end
    end
  end
end
