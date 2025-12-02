# frozen_string_literal: true

require 'circuitbox'

class CircuitBreaker
  def initialize(service, exceptions = [StandardError])
    @service = service.to_sym
    @exceptions = exceptions
    @sleep_window = Configs::ConfigServices.new.circuit_breaker_sleep_window.to_i
    @time_window = Configs::ConfigServices.new.circuit_breaker_time_window.to_i
    @volume_threshold = Configs::ConfigServices.new.circuit_breaker_volume_threshold.to_i
    @error_threshold = Configs::ConfigServices.new.circuit_breaker_error_threshold.to_i
  end

  def call
    Circuitbox.circuit(@service, {
                         exceptions: @exceptions,
                         sleep_window: @sleep_window,
                         time_window: @time_window,
                         volume_threshold: @volume_threshold,
                         error_threshold: @error_threshold
                       })
  end
end
