# frozen_string_literal: true

module Alerts
  class Channel
    def initialize(channel)
      @channel = channel
    end

    def channel
      # raise NoMethodError
      raise NotImplementedError,
            "#{self.class} has not implemented method '#{__method__}'"
    end
  end
end
