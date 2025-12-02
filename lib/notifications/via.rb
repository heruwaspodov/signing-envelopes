# frozen_string_literal: true

module Notifications
  class Via
    def call
      raise NotImplementedError,
            "#{self.class} has not implemented method '#{__method__}'"
    end
  end
end
