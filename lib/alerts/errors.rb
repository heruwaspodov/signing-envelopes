# frozen_string_literal: true

module Alerts
  module Errors
    class ChannelError < StandardError
      attr_reader :code

      def initialize(message = nil, code = 404)
        super(message)
        @code = code
      end
    end

    class ChannelConfigNotFound < Alerts::Errors::ChannelError; end
    class ChannelInvalid < Alerts::Errors::ChannelError; end
  end
end
