# frozen_string_literal: true

module Attachments
  class FromDocServicesV2 < AttachmentFileServices
    include DatadogMetricHelper

    def exec!
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      converter = Converters::DocConverter.new(@file, @tempfile_target.path)
      converter.convert
      duration = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start)
      send_gotenberg_elapsed_time(duration)

      @tempfile_target
    rescue StandardError, Gotenberg::ConversionError => e
      send_gotenberg_failed
      raise Gotenberg::ConversionError, e.message
    ensure
      send_gotenberg_success
    end
  end
end
