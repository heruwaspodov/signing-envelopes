# frozen_string_literal: true

module Envelopes
  class SignMultipleAnnotateServices < ApplicationService
    include DatadogMetricHelper

    def initialize(recipient_id)
      @recipient_id = recipient_id
    end

    def call
      return unless envelope_recipient.present? # return if envelope recipient is not found

      return if completed_all? # first check if already completed all will be return nil

      return if still_exec? # return if any envelope still in progress

      execute

      sign_next_annotate and return if any_enqueue?

      completed_all_annotations if completed_all?
    end

    private

      def log_info(message, extra = {})
        Log.info(">> #{self.class.name}##{__method__} (rec: #{@recipient_id}) #{message}", extra)
      end

      def sign_next_annotate
        Envelopes::ExecSignMultipleAnnotateWorker.perform_async(@recipient_id)

        log_info('queue next anotation')
      end

      def completed_all_annotations
        log_info('complete all anotations')
      end

      def envelope_recipient
        @envelope_recipient ||= EnvelopeRecipient.find_by_id @recipient_id
      end

      def envelope
        @envelope ||= envelope_recipient.envelope
      end

      def envelope_recipient_annotations
        @envelope_recipient_annotations ||= EnvelopeRecipientAnnotation
                                            .where(envelope_recipient_id: @recipient_id)
      end

      def still_exec?
        envelope_recipient_annotations.where(status: :in_progress).exists?
      end

      def any_enqueue?
        envelope_recipient_annotations.where(status: :enqueue).exists?
      end

      def completed_all?
        envelope_recipient_annotations.count.positive? &&
          envelope_recipient_annotations
            .where(status: :success).count == envelope_recipient_annotations.count
      end

      def data_execute
        @data_execute ||= envelope_recipient_annotations.where(status: :enqueue).first
      end

      def temp_doc
        return nil unless envelope&.doc&.attached?

        temp_doc = Tempfile.new([envelope.id, '.pdf'])
        temp_doc.binmode
        temp_doc.write(document.download)
        temp_doc.rewind
        temp_doc
      end

      def document
        envelope.signed_doc.present? ? envelope.signed_doc : envelope.doc
      end

      def signature
        return nil unless data_execute

        @signature ||= data_execute.envelope_recipient_annotation_signature
      end

      def temp_signature
        return nil unless signature&.signature&.attached?

        # i dont know why creating tempfile manually cannot read on HexaPDF, so use this
        Files::FileValidation.new(signature&.signature&.download).tempfile
      end

      def execute
        return unless data_execute.present?

        mark_as_in_progress
        sign_logging { sign! }
      rescue StandardError => e
        mark_as_error(e)
        send_envelope_signing_failed
      else
        attach_signed_doc!
        mark_as_success
      ensure
        remove_tempfile
      end

      def sign_logging
        log_info('signing start', Time.now)
        yield
        log_info('signing finish', Time.now)
      end

      # rubocop:disable Metrics/AbcSize
      def sign!
        # Return early if any required data is missing
        return unless data_execute && temp_doc && temp_signature

        img_annotation = Annotations::AnnotationSignature.new(
          temp_doc, temp_signature, data_execute.annotations['page']
        )
        img_annotation.recipient = envelope_recipient
        img_annotation.setup_dss(envelope.id)
        img_annotation.setup_attributes(data_execute.annotations)

        # process and assign for next step attachment
        @signed_file = img_annotation.process!
      end
      # rubocop:enable Metrics/AbcSize

      def mark_as_in_progress
        return unless data_execute

        data_execute.in_progress!
        log_info('in_progress annotate signature')
      end

      def mark_as_success
        return unless data_execute

        data_execute.success!
        log_info('success annotate signature')
      end

      def mark_as_error(error)
        return unless data_execute

        data_execute.failed!
        log_info('failed annotate signature', error)
      end

      def remove_tempfile
        temp_signature&.close! if defined?(temp_signature) && temp_signature
        temp_doc&.close! if defined?(temp_doc) && temp_doc
      end

      def attach_signed_doc!
        envelope_recipient.send(:attach_signed_doc!, @signed_file)
        log_info('success attach signed doc')
      end
  end
end
