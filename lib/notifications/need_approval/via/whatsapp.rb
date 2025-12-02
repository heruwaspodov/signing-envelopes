# frozen_string_literal: true

module Notifications
  module NeedApproval
    module Via
      class Whatsapp < Notifications::Via
        def initialize(to, approval_request)
          @to = to
          @approval_request = approval_request
        end

        def call
          ::Whatsapp::Templates::NeedApproval.new(
            ::Whatsapp::To.new(@to.phone, @to.name),
            @approval_request
          ).call
        end
      end
    end
  end
end
