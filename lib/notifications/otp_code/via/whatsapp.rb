# frozen_string_literal: true

module Notifications
  module OtpCode
    module Via
      class Whatsapp < Notifications::Via
        def initialize(to, otp_code)
          @to = to
          @otp_code = otp_code
        end

        def call
          ::Whatsapp::Templates::OtpCode.new(
            @to,
            @otp_code
          ).call
        end
      end
    end
  end
end
