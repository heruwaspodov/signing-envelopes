# frozen_string_literal: true

module Notifications
  module OtpCode
    class Sender < Notifications::Notify
      include WhatsappQuota

      def allowed_params
        %w[recipient otp_code envelope]
      end

      def via_whatsapp
        send_otp_via_whatsapp
      end

      def via_email
        send_otp_via_email
      end

      private

        def send_otp_via_whatsapp
          return if @recipient.phone.blank?
          return unless quota_allows_whatsapp?

          execute_whatsapp_send
        rescue StandardError => e
          Rails.logger.error "Failed to send OTP via WhatsApp: #{e.message}"
        end

        def quota_allows_whatsapp?
          if Flipper.enabled?(:ft_whatsapp_quota_improvements, doc_maker)
            whatsapp_allowed?(@recipient.phone)
          else
            whatsapp_allowed?
          end
        end

        def execute_whatsapp_send
          whatsapp_exec(
            Notifications::OtpCode::Via::Whatsapp,
            Whatsapp::To.new(@recipient.phone, @recipient.name),
            @otp_code
          )
        end

        def doc_maker
          @envelope.user
        end

        def send_otp_via_email
          return if @recipient.email.blank?

          execute_email_send
        rescue StandardError => e
          Rails.logger.error "Failed to send OTP via email: #{e.message}"
        end

        def execute_email_send
          OtpMailer.send_otp_code(@recipient, @otp_code, @envelope).deliver_now
        end
    end
  end
end
