# frozen_string_literal: true

module Requests
  class Sender
    def initialize(request = [])
      @request = request
    end

    def <<(request)
      @request << request
    end

    def >>(other)
      send(other)
    end

    def send(request)
      return unless request.present?

      request.handle_response(request.send)
    rescue RestClient::ExceptionWithResponse => e
      response = e.response.present? ? e.response : e.message
      request.handle_error(response, e)
    rescue StandardError => e
      request.handle_error(e.message, e)
    end
  end
end
