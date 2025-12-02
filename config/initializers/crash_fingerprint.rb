# frozen_string_literal: true

# rubocop:disable Style/GlobalStdStream
# rubocop:disable Style/SpecialGlobalVars
# Log boot so we know the PID/app actually started
Rails.logger.info("[BOOT] rails_env=#{Rails.env} pid=#{Process.pid}")

# Flush logs on every exit and tell us *why* we’re exiting
at_exit do
  exc = $!
  if exc.is_a?(SystemExit)
    Rails.logger.error("[AT_EXIT][EXIT] SystemExit status=#{exc.status} pid=#{Process.pid}")
  elsif exc
    Rails.logger.error("[AT_EXIT][CRASH] #{exc.class}: #{exc.message}")
    Rails.logger.error(exc.backtrace.join("\n")) if exc.backtrace
  else
    Rails.logger.info("[AT_EXIT][EXIT] normal pid=#{Process.pid}")
  end

  begin
    Rails.logger.flush if Rails.logger.respond_to?(:flush)
    STDOUT.flush
    STDERR.flush
  rescue StandardError
    # ignore
  end
end

# Catch shutdown signals early (K8s sends TERM first)
%w[TERM INT QUIT].each do |sig|
  Signal.trap(sig) do
    Rails.logger.info(
      "[AT_EXIT][SIGNAL] #{sig} received pid=#{Process.pid} — starting graceful shutdown"
    )
  end
end

# Make sure thread exceptions are surfaced loudly (incl. Puma threads)
Thread.abort_on_exception = true
Thread.report_on_exception = true
# rubocop:enable Style/SpecialGlobalVars
# rubocop:enable Style/GlobalStdStream
