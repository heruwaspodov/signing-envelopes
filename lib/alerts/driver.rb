# frozen_string_literal: true

module Alerts
  class Driver
    def initialize(channel, message)
      @channel = define_channel(channel)
      @message = message
    end

    def send!
      # raise NoMethodError
      raise NotImplementedError,
            "#{self.class} has not implemented method '#{__method__}'"
    end

    private

      def define_channel(channel)
        target_class = channel.titleize.remove(' ')
        service_class = "Alerts::#{self.class.name.demodulize}::Channels::#{target_class}"

        unless Kernel.const_defined? service_class
          raise Alerts::Errors::ChannelInvalid, I18n.t('error.validation.not_found')
        end

        Kernel.const_get(service_class).new(channel).channel
      end
  end
end
