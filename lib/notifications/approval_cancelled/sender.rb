# frozen_string_literal: true

module Notifications
  module ApprovalCancelled
    class Sender < Notifications::Notify
      include WhatsappQuota

      def allowed_params
        %w[approval_request]
      end

      def via_whatsapp
        wa_to_approver
      end

      def via_email
        mail_to_owner
        mail_to_recipients
      end

      def mail_to_owner
        Notifications::ApprovalCancelled::Via::Email.new(@approval_request.user.email,
                                                         @approval_request).call
      end

      def mail_to_recipients
        @approval_request.approval_request_approvers.map do |approver|
          # if email recipient same with email owner
          approver_email = approver.user.email
          next if @approval_request.user.email == approver_email

          Notifications::ApprovalCancelled::Via::Email.new(approver_email, @approval_request).call
        end
      end

      # rubocop: disable Metrics/AbcSize
      def wa_to_approver
        @approval_request.approval_request_approvers.map do |approver|
          # next if blank phone number in recipient
          next if approver.user.phone.blank?

          if Flipper.enabled?(:ft_whatsapp_quota_improvements, @approval_request.user)
            next unless whatsapp_allowed?(approver.user.phone)
          else
            next unless whatsapp_allowed?
          end

          whatsapp_exec(
            Notifications::ApprovalCancelled::Via::Whatsapp,
            Whatsapp::To.new(approver.user.phone, approver.user.full_name), @approval_request
          )
        end
      end
      # rubocop: enable Metrics/AbcSize
    end
  end
end
