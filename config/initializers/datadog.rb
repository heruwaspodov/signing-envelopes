# frozen_string_literal: true

unless Rails.env.test?
  Datadog.configure do |config|
    config.tracing.enabled = ENV.fetch('DATADOG_APM_ENABLE', 'false') == 'true'
    config.env = ENV.fetch('DATADOG_APM_SERVICE_NAME', 'e_sign')
    config.version = File.read(File.expand_path('../../VERSION', __dir__)).strip
    config.tags = {
      'project' => 'esign',
      'team' => 'esign'
    }
    config.tracing.instrument :rails, distributed_tracing: true, middleware: true

    # Enable action view if rake assets precompile is enabled
    if ENV['RAILS_SERVE_STATIC_FILES'].present?
      config.tracing.instrument :rails, template_base_path: 'public/'
      config.tracing.instrument :action_view, template_base_path: 'public/'
    end

    # Set other dependencies with default options
    config.tracing.instrument :active_record, service_name: 'e_sign-postgres'
    config.tracing.instrument :pg, enabled: false
    config.tracing.instrument :active_job, service_name: 'active_job'
    config.tracing.instrument :active_support, service_name: 'active_support'
    config.tracing.instrument :action_mailer, service_name: 'action_mailer'
    config.tracing.instrument :action_pack, service_name: 'action_pack'
    config.tracing.instrument :rest_client, service_name: 'esign_rest_client', split_by_domain: true
    config.tracing.instrument :sidekiq, service_name: 'sidekiq'
    config.tracing.instrument :redis, service_name: 'redis'

    # log injection
    config.tracing.log_injection = true
  end

  at_exit do
    # on version 5.x, close method should be only called 1 time at exit because new threading model
    # documentation can be found in this link https://github.com/DataDog/dogstatsd-ruby#migrating-from-v4x-to-v5x
    # and the docs about the new threading model can be found here https://github.com/DataDog/dogstatsd-ruby#threading-model
    DatadogLib::Metrics.close
  end
end
