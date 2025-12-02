# frozen_string_literal: true

module Notifications
  module InviteToSign
    class Sender < Notifications::Notify
      include WhatsappQuota
      def allowed_params
        %w[recipient envelope]
      end

      def via_whatsapp
        if Flipper.enabled?(:ft_whatsapp_quota_improvements, @envelope.user)
          return unless whatsapp_allowed?(@recipient.phone)
        else
          return unless whatsapp_allowed?
        end

        whatsapp_exec(Notifications::InviteToSign::Via::Whatsapp, @envelope, @recipient)
      end

      def via_email
        Notifications::InviteToSign::Via::Email.new(@recipient).call
      end
    end
  end
end
