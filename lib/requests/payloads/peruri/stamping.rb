# frozen_string_literal: true

module Requests
  module Payloads
    module Peruri
      class Stamping < HttpRequest
        attr_accessor :params

        def initialize(params = {})
          @params = params
        end

        def send
          RestClient.post stamping_url, payload.to_json, headers
        end

        private

          def stamping_url
            "#{ENV['PERURI_SIGN_ADAPTER_URL']}/adapter/pdfsigning/rest/docSigningZ"
          end

          def payload
            {
              certificatelevel: @params[:certificate_level],
              docpass: @params[:document_password],
              jwToken: @params[:access_token],
              location: @params[:location],
              profileName: @params[:profile_name],
              reason: @params[:reason],
              refToken: @params[:serial_number],
              spesimenPath: @params[:path_stamp],
              src: @params[:path_doc_unsigned],
              dest: @params[:path_doc_signed],
              visLLX: @params[:vis_llx],
              visLLY: @params[:vis_lly],
              visURX: @params[:vis_urx],
              visURY: @params[:vis_ury],
              visSignaturePage: @params[:page]
            }
          end
      end
    end
  end
end
