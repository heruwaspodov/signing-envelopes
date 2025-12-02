# frozen_string_literal: true

module Api
  module V1
    class SingleSignController < Api::V1::ApiController
      before_action :reset_attachment

      def signing
        Log.info("Trace envelope #{id_params} >> START signing!!!", Time.now)

        response = process_signing params

        Log.info("Trace envelope #{id_params} >> FINISH signing!!!", Time.now)

        json_response({ message: response[:message] }, :ok, false)
      end

      private

        def envelope
          @envelope ||= Envelope.where(is_certified: false).first
        end

        def reset_attachment
          envelope.reset_doc_attachment
          envelope.reset_signed_doc_attachment

          envelope.reload
        end

        def process_signing(params)
          Log.info("Trace envelope #{id_params} >> start signing process", Time.now)

          response = sign_service_process.new(envelope, params).call

          Log.info("Trace envelope #{id_params} >> end signing process", Time.now)

          response
        end

        def id_params
          envelope.id
        end

        def sign_service_process
          is_certified = envelope.try(:is_certified).to_bool
          is_certified ? Envelopes::SignMultipleCertServices : Envelopes::SignServices
        end
    end
  end
end
