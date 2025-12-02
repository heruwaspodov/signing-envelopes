# frozen_string_literal: true

require 'datadog/statsd'
require 'active_support/core_ext/module/delegation'

module DatadogLib
  class Metrics
    include Singleton

    class << self
      delegate_missing_to :instance
    end

    delegate_missing_to :@statsd

    DD_HOST = ENV.fetch(
      'DD_AGENT_HOST',
      ::Datadog::Statsd::ConnectionCfg::DEFAULT_HOST
    )

    DD_PORT = Integer(
      ENV.fetch(
        'DD_AGENT_PORT',
        ::Datadog::Statsd::ConnectionCfg::DEFAULT_PORT
      )
    )

    def self.reset_instance!
      Singleton.__init__(self)
    end

    def initialize
      @statsd = ::Datadog::Statsd.new(
        DD_HOST,
        DD_PORT,
        tags: default_tags,
        logger: Rails.logger
      )
    end

    private

      def default_tags
        %W[
          env:#{ENV.fetch('DATADOG_APM_SERVICE_NAME', 'msign-backend-alicloud')},
          version:#{App::VERSION}
        ].freeze
      end
  end
end
