# frozen_string_literal: true

module Notifications
  module ApprovalRejected
    class Sender < Notifications::Notify
      include WhatsappQuota

      def allowed_params
        %w[approval_request]
      end

      def via_whatsapp
        wa_to_owner
        wa_to_approver
      end

      def via_email
        mail_to_owner
        mail_to_recipients
      end

      def mail_to_owner
        Notifications::NeedApproval::Via::Email.new(@approval_request.user.email,
                                                    @approval_request).call
      end

      def mail_to_recipients
        @approval_request.approval_request_approvers.map do |approver|
          # if email recipient same with email owner
          approver_email = approver.user.email
          next if @approval_request.user.email == approver_email

          Notifications::NeedApproval::Via::Email.new(approver_email, @approval_request).call
        end
      end

      def wa_to_owner
        owner = @approval_request.user

        # check notification setting by owner

        if Flipper.enabled?(:ft_whatsapp_quota_improvements, @approval_request.user)
          return unless whatsapp_allowed?(owner.phone)
        else
          return unless whatsapp_allowed?
        end

        whatsapp_exec(
          Notifications::ApprovalRejected::Via::Whatsapp,
          Whatsapp::To.new(owner.whatsapp, owner.full_name),
          @approval_request
        )
      end

      def approvers(current_approver)
        current_order = current_approver.approval_request_layer.order
        approval_request = current_approver.approval_request
        approvers = []
        layers = approval_request.approval_request_layers.where(order: 0..current_order)
        add_approvers(approvers, layers)
        approvers.uniq
      end

      def add_approvers(approvers, layers)
        layers.each do |layer|
          layer.approval_request_approvers.each do |approver|
            approvers << approver
          end
        end
      end

      def rejector
        @approval_request.approval_request_approvers.rejected.first
      end

      # rubocop: disable Metrics/AbcSize
      def wa_to_approver
        approvers(rejector).map do |approver|
          # next if blank phone number in recipient
          next if approver.user.phone.blank?

          if Flipper.enabled?(:ft_whatsapp_quota_improvements, @approval_request.user)
            next unless whatsapp_allowed?(approver.user.phone)
          else
            next unless whatsapp_allowed?
          end

          whatsapp_exec(
            Notifications::ApprovalRejected::Via::Whatsapp,
            Whatsapp::To.new(approver.user.phone, approver.user.full_name), @approval_request
          )
        end
      end
      # rubocop: enable Metrics/AbcSize
    end
  end
end
