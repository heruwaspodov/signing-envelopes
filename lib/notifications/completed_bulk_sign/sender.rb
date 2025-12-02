# frozen_string_literal: true

module Notifications
  module CompletedBulkSign
    class Sender < Notifications::Notify
      def allowed_params
        %w[to envelope_ids]
      end

      def via_email
        mail_to_sender
      end

      def mail_to_sender
        Notifications::CompletedBulkSign::Via::Email.new(@to, @envelope_ids).call
      end
    end
  end
end
