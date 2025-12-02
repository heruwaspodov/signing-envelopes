# frozen_string_literal: true

module Notifications
  module Stamped
    module Via
      class Whatsapp < Notifications::Via
        def initialize(to, envelope, recipient)
          @to = to
          @envelope = envelope
          @recipient = recipient
        end

        def call
          ::Whatsapp::Templates::StampingCompleted.new(
            ::Whatsapp::To.new(@to.phone, @to.name),
            @envelope,
            @recipient
          ).call
        end
      end
    end
  end
end
