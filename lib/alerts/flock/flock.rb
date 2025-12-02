# frozen_string_literal: true

module Alerts
  module Flock
    class Flock < Alerts::Driver
      def send!
        notifier = ::Flock::Notifier.new @channel
        notifier.ping({ 'flockml' => "<flockml>#{@message.gsub(/[\r\n]+/, '<br>')}</flockml>" })
      end
    end
  end
end
