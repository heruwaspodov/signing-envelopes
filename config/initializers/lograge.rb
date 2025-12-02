# frozen_string_literal: true

require 'datadog/tracing'

include LoggerHelper

excluded_request_headers = %w[
  SERVER_SOFTWARE
  GATEWAY_INTERFACE
  SERVER_NAME
  SERVER_PROTOCOL
  SERVER_PORT
  REQUEST_METHOD
  QUERY_STRING
  SCRIPT_NAME
  PATH_INFO
  REMOTE_ADDR
  HTTP_COOKIE
  HTTP_VERSION
  HTTP_UPGRADE_INSECURE_REQUESTS
  HTTP_CACHE_CONTROL
  HTTP_ACCEPT_ENCODING
  HTTP_ACCEPT
  HTTP_ACCEPT_LANGUAGE
  HTTP_SEC_FETCH_SITE
  HTTP_SEC_FETCH_MODE
  HTTP_SEC_FETCH_USER
  HTTP_SEC_FETCH_DEST
  HTTP_X_ENVOY_ORIGINAL_PATH
  HTTP_X_ENVOY_INTERNAL
  HTTP_X_ENVOY_EXPECTED_RQ_TIMEOUT_MS
  HTTP_X_NEWRELIC_ID
  HTTP_X_NEWRELIC_TRANSACTION
  HTTP_X_DATADOG_TRACE_ID
  HTTP_X_DATADOG_PARENT_ID
  HTTP_X_DATADOG_SAMPLING_PRIORITY
]

Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.ignore_actions = ['api#index', 'api/v1/api#index', 'ErrorsController#internal_server_error']
  config.lograge.base_controller_class = ['ActionController::API']
  config.lograge.formatter = Lograge::Formatters::Json.new

  config.lograge.custom_options = lambda do |event|
    headers = event.payload[:headers].env.select do |k, _|
      (k.in?(ActionDispatch::Http::Headers::CGI_VARIABLES) || k =~ /^HTTP_/) && !excluded_request_headers.include?(k)
    end

    correlation = Datadog::Tracing.correlation

    custom_options = {
      version: App::VERSION,
      time: Time.now,
      rails_env: Rails.env,
      host: event.payload[:host],
      remote_ip: event.payload[:remote_ip],
      request_headers: headers,
      request_params: sanitize_params(event.payload[:params]),
      dd: {
        trace_id: correlation.trace_id,
        span_id: correlation.span_id,
        env: correlation.env
      }
    }

    if event.payload[:exception]
      exception = event.payload[:exception_object]
      custom_options[:error] = {
        message: exception.message,
        backtrace: exception.backtrace.take(5) # Limit the backtrace for brevity
      }
    end

    # add soc-monitoring
    custom_options['soc-monitoring'] = true

    custom_options.compact
  end

  config.lograge.custom_payload do |controller|
    custom_payload = {
      request_id: controller.request.request_id,
    }

    custom_payload.compact
  end
end
