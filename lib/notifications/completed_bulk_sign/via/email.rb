# frozen_string_literal: true

module Notifications
  module CompletedBulkSign
    module Via
      class Email < Notifications::Via
        def initialize(to, envelope_ids)
          @to = to
          @envelope_ids = envelope_ids
        end

        def call
          DocumentNotificationMailer.bulk_sign_completed(@to, @envelope_ids).deliver_later
        end
      end
    end
  end
end
