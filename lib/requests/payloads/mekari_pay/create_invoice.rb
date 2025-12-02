# frozen_string_literal: true

module Requests
  module Payloads
    module MekariPay
      class CreateInvoice < HttpRequest
        attr_accessor :external_id, :transaction_number, :original_amount, :remaining_amount,
                      :rounding, :due_date, :description, :company_name, :company_email,
                      :customer_name, :customer_phone, :customer_email, :payment_methods, :items,
                      :enable_charge_fee_to_customer

        def initialize(params)
          allowed_params.each do |param|
            next unless params[param.to_sym].present?

            instance_variable_set("@#{param}", params[param.to_sym])
          end
        end

        def allowed_params
          %w[external_id transaction_number original_amount remaining_amount rounding due_date
             description company_name company_email customer_name customer_phone customer_email
             payment_methods items enable_charge_fee_to_customer]
        end

        def send
          RestClient.post url, payload, set_header
        end

        def after_success(data)
          result = Struct.new(:response, :error)
          result.new(data, nil)
        end

        private

          def set_header
            headers.merge({
                            authorization: ENV['MEKARI_PAY_API_KEY']
                          })
          end

          def url
            "#{ENV['MEKARI_PAY_URL']}/api/v1/invoices"
          end

          def payload
            {
              external_id: @external_id,
              transaction_number: @transaction_number,
              original_amount: @original_amount,
              remaining_amount: @remaining_amount,
              rounding: @rounding,
              due_date: @due_date,
              description: @description,
              company: set_company,
              customer: set_customer,
              payment_methods: @payment_methods,
              items: @items,
              enable_charge_fee_to_customer: @enable_charge_fee_to_customer
            }
          end

          def set_company
            {
              name: @company_name,
              email: @company_email
            }
          end

          def set_customer
            {
              name: @customer_name,
              email: @customer_email,
              phone: @customer_phone
            }
          end
      end
    end
  end
end
