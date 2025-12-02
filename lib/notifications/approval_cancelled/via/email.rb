# frozen_string_literal: true

module Notifications
  module ApprovalCancelled
    module Via
      class Email < Notifications::Via
        def initialize(approval_request)
          @approval_request = approval_request
        end

        def call
          ApprovalRequestMailer.cancelled(@approval_request.id).deliver_later
        end
      end
    end
  end
end
