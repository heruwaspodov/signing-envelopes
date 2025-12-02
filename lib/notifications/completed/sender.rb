# frozen_string_literal: true

module Notifications
  module Completed
    class Sender < Notifications::Notify
      include WhatsappQuota

      def allowed_params
        %w[recipient envelope]
      end

      def via_whatsapp
        wa_to_owner
        wa_to_recipient
      end

      def via_email
        mail_to_owner
        mail_to_recipients
      end

      def mail_to_owner
        Notifications::Completed::Via::Email.new(@envelope.user.email, @envelope, @recipient).call
      end

      def mail_to_recipients
        @envelope.recipients.map do |recipient|
          next if recipient.disable_document_access.to_bool

          # if email recipient same with email owner
          rec_email = recipient.user.present? ? recipient.user.email : recipient.email
          next if @envelope.user.email == rec_email

          Notifications::Completed::Via::Email.new(rec_email, @envelope, recipient).call
        end
      end

      # rubocop: disable Metrics/AbcSize
      # rubocop: disable Metrics/MethodLength
      def wa_to_owner
        owner = @envelope.user

        # check notification setting by owner
        return unless notify_owner?(owner)

        if Flipper.enabled?(:ft_whatsapp_quota_improvements, @envelope.user)
          # Use whatsapp number if available, otherwise fall back to phone
          phone_number = owner.whatsapp.presence || owner.phone
          return if phone_number.blank?
          return unless whatsapp_allowed?(phone_number)

          whatsapp_exec(
            Notifications::Completed::Via::Whatsapp,
            Whatsapp::To.new(phone_number, owner.full_name),
            @envelope,
            nil
          )
        else
          # Old system: check whatsapp_allowed but don't require phone number
          return unless whatsapp_allowed?

          whatsapp_exec(
            Notifications::Completed::Via::Whatsapp,
            Whatsapp::To.new(owner.whatsapp, owner.full_name),
            @envelope,
            nil
          )
        end
      end

      def wa_to_recipient
        @envelope.recipients.with_completed_wa_notify.map do |recipient|
          next if recipient.disable_document_access.to_bool
          # if email recipient same with email owner
          next if @envelope.user.email == recipient.email

          # next if blank phone number in recipient
          next if recipient.phone.blank?

          if Flipper.enabled?(:ft_whatsapp_quota_improvements,
                              @envelope.user) && !whatsapp_allowed?(recipient.phone)
            next
          end

          # Old system: don't check whatsapp_allowed, let quota deduction handle it

          whatsapp_exec(
            Notifications::Completed::Via::Whatsapp,
            Whatsapp::To.new(recipient.phone, recipient.name), @envelope, recipient
          )
        end
      end
      # rubocop: enable Metrics/AbcSize
      # rubocop: enable Metrics/MethodLength
    end
  end
end
