# frozen_string_literal: true

module Envelopes
  class SignServices < ApplicationService
    attr_accessor :envelope

    def initialize(envelope, params = {})
      @params       = params
      @envelope     = envelope.reload
      @signature    = Files::FileValidation.new(params[:signature]) if params[:signature]
      @initial      = Files::FileValidation.new(params[:initial]) if params[:initial]
    end

    def call
      Log.info("Trace envelope #{@envelope.id} >> start set signer", Time.now)
      set_signer!
      Log.info("Trace envelope #{@envelope.id} >> finish set signer", Time.now)
      process!

      @response
    ensure
      close_tempfile(@signature_image)
      close_tempfile(@initial_image)
    end

    private

      def process!
        steps = %i[
          annotate!
          sign_document!
          cert!
        ]

        steps.each do |step|
          result = log_step(step) { send(step) }

          break if step == :cert! && result == false
        end
      end

      def set_signer!
        # Reload recipients association to ensure fresh data
        @envelope.recipients.reload
        @recipient = @envelope.recipients.first
        # Reload recipient to ensure envelope association is fresh
        @recipient.reload
      end

      def sign_document!
        @recipient.update!(signed_at: DateTime.now)

        @response = response(true, I18n.t('error.validation.document_status', doc_status: 'signed'))
      end

      def annotate!
        return if @recipient.no_signature?

        params_annotation = EnvelopeRecipient::PARAMS_ANNOTATION
        annotations = params_annotation.new(signature_image, initial_image, nil, nil)

        @recipient.annotate!(annotations, standard_annotations)
      end

      def signature_image
        @signature_image ||= generate_signature
      end

      def initial_image
        @initial_image ||= generate_initial
      end

      def generate_signature
        signature_ann = signature_annotation
        return unless signature_ann.present?

        @signature.tempfile if @signature.present?
      end

      def generate_initial
        initial_ann = initial_annotation
        return unless initial_ann.present?

        @initial.tempfile if @initial.present?
      end

      def signature_annotation
        return unless @recipient.present?

        @recipient.annotations.select { |a| %w[signature].include? a['type_of'] }.first
      end

      def initial_annotation
        return unless @recipient.present?

        @recipient.annotations.select { |a| %w[initial].include? a['type_of'] }.first
      end

      def close_tempfile(tempfile)
        return unless tempfile.present?

        tempfile.close
        tempfile.unlink
      end

      def cert!
        return if @envelope.is_certified

        process_cert = @recipient.cert!

        return true if process_cert

        process_rollback

        false
      end

      def response(status, message)
        # Reload envelope to get fresh signed_doc attachment data
        @envelope.reload

        response_data = {
          status: status,
          message: message
        }

        # Add signed_doc URL if envelope has signed_doc attached
        if @envelope.signed_doc.attached?
          response_data[:signed_doc_url] = Rails.application.routes.url_helpers.rails_blob_path(
            @envelope.signed_doc,
            only_path: true,
            disposition: 'attachment'
          )
        end

        response_data
      end

      def standard_annotations
        annotations = {}

        return annotations unless @params.present?

        EnvelopeRecipient::STANDARD_ANNOTATION.each do |param|
          standard_annotation = @params[param.to_sym]
          next unless standard_annotation.present?

          standard_annotation.each do |annotation|
            # set the annotation short-id as the key, and the annotation base64 as the value
            annotations[annotation['id']] = Files::FileValidation.new(annotation['value']).tempfile
          end
        end

        annotations.with_indifferent_access
      end

      def rollback_recipient
        @recipient.signed_at = nil
        @recipient.save
      end

      def process_rollback
        rollback_recipient

        @response = response(false, I18n.t('error.signing.failed_cert'))
      end

      def log_step(step)
        Log.info("Trace envelope #{@envelope.id} >> start #{step}", Time.now)

        result = yield

        Log.info("Trace envelope #{@envelope.id} >> finish #{step}", Time.now)

        result
      end
  end
end
