# frozen_string_literal: true

module Notifications
  module Stamped
    class Sender < Notifications::Notify
      include WhatsappQuota

      def allowed_params
        %w[recipient envelope]
      end

      def via_email
        mail_to_owner
        mail_to_recipients
      end

      def via_whatsapp
        wa_to_owner
        wa_to_recipient
      end

      def mail_to_owner
        Notifications::Stamped::Via::Email.new(@envelope.user.email, @envelope, @recipient).call
      end

      def mail_to_recipients
        @envelope.recipients.map do |recipient|
          # if email recipient same with email owner
          rec_email = recipient.user.present? ? recipient.user.email : recipient.email
          next if @envelope.user.email == rec_email

          Notifications::Stamped::Via::Email.new(rec_email, @envelope, recipient).call
        end
      end

      def wa_to_owner
        owner = @envelope.user

        return unless notify_owner?(owner)

        if Flipper.enabled?(:ft_whatsapp_quota_improvements, @envelope.user)
          return unless whatsapp_allowed?(owner.phone)
        else
          return unless whatsapp_allowed?
        end

        whatsapp_exec(
          Notifications::Stamped::Via::Whatsapp,
          Whatsapp::To.new(owner.phone, owner.full_name),
          @envelope,
          nil
        )
      end

      # rubocop: disable Metrics/AbcSize
      def wa_to_recipient
        @envelope.recipients.map do |recipient|
          # if email recipient same with email owner
          next if @envelope.user.email == recipient.email

          # next if blank phone number in recipient
          next if recipient.phone.blank?

          if Flipper.enabled?(:ft_whatsapp_quota_improvements, @envelope.user)
            next unless whatsapp_allowed?(recipient.phone)
          else
            next unless whatsapp_allowed?
          end

          whatsapp_exec(
            Notifications::Stamped::Via::Whatsapp,
            Whatsapp::To.new(recipient.phone, recipient.name), @envelope, recipient
          )
        end
      end
      # rubocop: enable Metrics/AbcSize
    end
  end
end
