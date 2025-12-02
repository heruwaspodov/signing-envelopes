# frozen_string_literal: true

module Notifications
  module InviteToSign
    module Via
      class Whatsapp < Notifications::Via
        def initialize(envelope, recipient)
          @envelope = envelope
          @recipient = recipient
        end

        def call
          ::Whatsapp::Templates::InviteToSign.new(
            ::Whatsapp::To.new(@recipient.phone, @recipient.name),
            @envelope,
            @recipient
          ).call
        end
      end
    end
  end
end
