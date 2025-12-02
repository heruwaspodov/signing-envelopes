# frozen_string_literal: true

module Alerts
  class Notify
    attr_reader :notify

    def initialize(channel, message)
      @channel = channel
      @message = message
      @notify = []
    end

    def via_flock
      @notify << Alerts::Flock::Flock.new(@channel, @message)
    end

    def via_google_chat
      @notify << Alerts::GoogleChat::GoogleChat.new(@channel, @message)
    end

    def send!
      return @notify unless @notify.present?

      @notify.map(&:send!)
    end
  end
end
