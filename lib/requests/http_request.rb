# frozen_string_literal: true

module Requests
  class HttpRequest
    def send; end

    def headers
      {
        accept: :json,
        content_type: :json
      }
    end

    def after_success(data)
      result = Struct.new(:response)
      result.new(data)
    end

    def after_error(data, error)
      result = Struct.new(:response, :error)
      result.new(data, error)
    end

    def original_response
      @with_original_response = true
      self
    end

    def handle_response(response)
      return handle_original_response if @with_original_response

      result = JSON.parse(response.body)

      after_success(result)
    rescue StandardError
      response
    end

    def handle_original_response
      JSON.parse(response.body)
    rescue StandardError
      response.body
    end

    def handle_error(response, error)
      log_error_response(response) if Flipper.enabled?(:ft_log_http_errors)

      result = JSON.parse(response)

      after_error(result, error.to_s)
    rescue StandardError
      log_error_response(response) if Flipper.enabled?(:ft_log_http_errors)

      after_error(result, error.to_s)
    end

    def log_error_response(response)
      subject = "#{self.class} HTTP request error"
      if response.nil?
        Log.error(subject, 'failed: response is nil')
      else
        Log.error(subject, "status: #{response.code}, body: #{response.body}")
      end
    end
  end
end
