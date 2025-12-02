# frozen_string_literal: true

module Notifications
  module ApprovalRejected
    module Via
      class Whatsapp < Notifications::Via
        def initialize(to, approval_request)
          @to = to
          @approval_request = approval_request
        end

        def call
          ::Whatsapp::Templates::ApprovalRejected.new(
            ::Whatsapp::To.new(@to.phone, @to.name),
            @approval_request
          ).call
        end
      end
    end
  end
end
