# frozen_string_literal: true

module Notifications
  module Stamped
    module Via
      class Email
        attr_reader :envelope, :recipient, :to

        def initialize(to, envelope, recipient)
          @to = to
          @recipient = recipient
          @envelope = envelope
        end

        def call
          DocumentNotificationMailer.stamped(@to, @envelope, @recipient).deliver_later
        end
      end
    end
  end
end
