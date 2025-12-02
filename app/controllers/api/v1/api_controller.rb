# frozen_string_literal: true

module Api
  module V1
    class ApiController < ::ApiController
      def index
        render json: {
          data: {
            version: App::VERSION
          },
          status: :ok,
          error: false
        }
      end
    end
  end
end
