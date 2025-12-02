# frozen_string_literal: true

module Envelopes
  module SignMultipleCertBehavior
    def initialize(envelope, params = {})
      @certified_doc_signature = params[:certified_doc_signature] if params[:certified_doc_signature]

      super
    end

    private

      def annotate!
        signature = @signature.tempfile if @signature.present?
        initial = @initial.tempfile if @initial.present?

        params_annotation = EnvelopeRecipient::PARAMS_ANNOTATION
        annotations = params_annotation.new(signature, initial, @certified_doc_signature)

        @recipient.annotate!(annotations)
      end
  end
end
