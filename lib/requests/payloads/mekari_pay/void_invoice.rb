# frozen_string_literal: true

module Requests
  module Payloads
    module MekariPay
      class VoidInvoice < HttpRequest
        attr_accessor :invoice_id

        def initialize(invoice_id)
          @invoice_id = invoice_id
        end

        def send
          RestClient.put url, nil, set_header
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
            "#{ENV['MEKARI_PAY_URL']}/api/v1/invoices/#{@invoice_id}/void"
          end
      end
    end
  end
end
