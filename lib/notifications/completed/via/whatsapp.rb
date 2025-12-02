# frozen_string_literal: true

module Notifications
  module Completed
    module Via
      class Whatsapp < Notifications::Via
        def initialize(to, envelope, recipient)
          @to = to
          @envelope = envelope
          @recipient = recipient
        end

        def call
          ::Whatsapp::Templates::Completed.new(
            ::Whatsapp::To.new(@to.phone, @to.name),
            @envelope,
            @recipient
          ).call
        end
      end
    end
  end
end
