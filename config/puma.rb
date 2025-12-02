# frozen_string_literal: true

require 'puma/plugin/statsd'

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `worker_timeout` threshold that Puma will use to wait before
# terminating a worker in development environments.
#
worker_timeout 3600 if ENV.fetch('RAILS_ENV', 'development') == 'development'

# Specifies the `port` that Puma will listen on to receive requests;
# default is 3000.
port ENV.fetch('PORT', 3000)

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch('RAILS_ENV', 'development')

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
workers ENV.fetch('WEB_CONCURRENCY', 1)

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# Send key puma metrics to statsd
plugin :statsd

# Configure statsd plugin to send metrics to Datadog agent
# Send key puma metrics to statsd
if ENV['STATSD_HOST'] && ENV['STATSD_PORT']
  ENV['STATSD_ADDR'] = "udp://#{ENV['STATSD_HOST']}:#{ENV['STATSD_PORT']}"
  ENV['STATSD_PREFIX'] = 'puma'
end

# ---- unbuffered logs in containers ----
$stdout.sync = true
$stderr.sync = true

# ---- ActiveRecord: disconnect in master, reconnect in workers ----
before_fork do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

# add establish_connection to ActiveRecord when puma workers boot
on_worker_boot do
  start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

  Rails.logger.info("[PUMA] on_worker_boot pid=#{Process.pid}")
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)

  duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
  Rails.logger.info("[PUMA] on_worker_boot finished pid=#{Process.pid} (#{duration.round(3)}s)")
end

on_worker_shutdown do
  Rails.logger.warn("[PUMA] on_worker_shutdown pid=#{Process.pid}")
end

# (Optional but useful) catches exceptions that bubble past Rack in a worker
lowlevel_error_handler do |ex, env|
  req = begin
    ActionDispatch::Request.new(env)
  rescue StandardError
    nil
  end
  msg = {
    class: ex.class,
    message: ex.message,
    path: req&.path,
    method: req&.request_method,
    timestamp: Time.current.iso8601
  }
  Rails.logger.error("[PUMA LOWLEVEL] #{msg.to_json}")
  Rails.logger.error(ex.backtrace.join("\n")) if ex.backtrace
  [500, { 'Content-Type' => 'text/plain' }, ['Internal Server Error']]
end

# Enable a control server for stats
activate_control_app 'tcp://127.0.0.1:9293', { no_token: true }
