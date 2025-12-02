# frozen_string_literal: true

module Notifications
  module NeedApproval
    module Via
      class Email < Notifications::Via
        def initialize(user_id, approval_request_id)
          @user_id = user_id
          @approval_request_id = approval_request_id
        end

        def call
          ApprovalRequestMailer.need_approval(@user_id, @approval_request_id).deliver_later
        end
      end
    end
  end
end
