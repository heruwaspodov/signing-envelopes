# frozen_string_literal: true

module Notifications
  module InviteToSign
    module Via
      class Email < Notifications::Via
        attr_reader :recipient

        def initialize(recipient)
          @recipient = recipient
        end

        def call
          DocumentNotificationMailer.invite_to_sign(@recipient).deliver_later
        end
      end
    end
  end
end
