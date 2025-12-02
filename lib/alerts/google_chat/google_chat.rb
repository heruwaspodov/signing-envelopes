# frozen_string_literal: true

module Alerts
  module GoogleChat
    class GoogleChat < Alerts::Driver
      def send!
        sender = Requests::Sender.new
        sender >> Requests::Payloads::GoogleChat::Webhook.new(@channel, @message)
      end
    end
  end
end
