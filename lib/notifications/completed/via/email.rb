# frozen_string_literal: true

module Notifications
  module Completed
    module Via
      class Email < Notifications::Via
        def initialize(to, envelope, recipient)
          @to = to
          @recipient = recipient
          @envelope = envelope
        end

        def call
          if @envelope.with_meterai?
            DocumentNotificationMailer.completed_with_meterai(@to, @envelope,
                                                              @recipient).deliver_later
          else
            DocumentNotificationMailer.completed(@to, @envelope, @recipient).deliver_later
          end
        end
      end
    end
  end
end
