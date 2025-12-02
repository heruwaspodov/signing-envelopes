# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module DatadogMetricHelper
  # use this method to add_ltv process metrics to datadog
  # the metrics will be used to monitor the duration or latency of add_ltv process
  #
  # @param [Integer] duration
  # @return [void]
  def send_add_ltv_duration(duration)
    DatadogLib::Metrics.timing(
      'msign_backend.add_ltv.duration',
      duration
    )
  end

  def send_add_ltv_hits
    DatadogLib::Metrics.increment(
      'msign_backend.add_ltv.hits'
    )
  end

  def send_add_ltv_errors(tags = {})
    DatadogLib::Metrics.increment(
      'msign_backend.add_ltv.errors',
      tags: tags
    )
  end

  def send_envelope_stamping_success(tags = {})
    DatadogLib::Metrics.increment(
      'msign_backend.envelope_stamping.success',
      tags: tags
    )
  end

  def send_stamping_hits(tags = {})
    DatadogLib::Metrics.increment(
      'msign_backend.meterai_stamping.hits',
      tags: tags
    )
  end

  def send_stamping_status(status, tags = {})
    DatadogLib::Metrics.increment(
      'msign_backend.meterai_stamping.status',
      tags: tags.merge({ stamping_status: status })
    )
  end

  def send_envelope_signing_success
    DatadogLib::Metrics.increment(
      'msign_backend.envelope.signing.status',
      tags: %w[status:success error:false]
    )
  end

  def send_envelope_signing_failed
    DatadogLib::Metrics.increment(
      'msign_backend.envelope.signing.status',
      tags: %w[status:failed error:true]
    )
  end

  def send_generate_sn_success
    DatadogLib::Metrics.increment(
      'msign_backend.generate_sn.status',
      tags: %w[status:success error:false]
    )
  end

  def send_generate_sn_failed(options = {})
    keys = options.map { |k, v| "#{k}:#{v}" }
    DatadogLib::Metrics.increment(
      'msign_backend.generate_sn.status',
      tags: %w[status:failed error:true] + keys
    )
  end

  def send_tracking_stamping_success
    DatadogLib::Metrics.increment(
      'msign_backend.stamping.status',
      tags: %w[status:success error:false]
    )
  end

  def send_tracking_stamping_failed(options = {})
    keys = options.map { |k, v| "#{k}:#{v}" }
    DatadogLib::Metrics.increment(
      'msign_backend.stamping.status',
      tags: %w[status:failed error:true] + keys
    )
  end

  def send_envelope_elapsed_time(time, name)
    DatadogLib::Metrics.gauge(
      "msign_backend.envelope.#{name}.elapsed_time",
      time,
      tags: %w[status:success error:false]
    )
  end

  def send_sn_rotation_attempt(attempts, tags = [])
    DatadogLib::Metrics.gauge(
      'msign_backend.sn_rotation.attempts',
      attempts,
      tags: tags
    )
  end

  def send_psre_signing_success
    DatadogLib::Metrics.increment(
      'msign_backend.psre_signing.status',
      tags: %w[status:success error:false]
    )
  end

  def send_psre_signing_failed
    DatadogLib::Metrics.increment(
      'msign_backend.psre_signing.status',
      tags: %w[status:failed error:true]
    )
  end

  def send_psre_autosign_success
    DatadogLib::Metrics.increment(
      'msign_backend.psre_auto_signing.status',
      tags: %w[status:success error:false]
    )
  end

  def send_psre_autosign_failed
    DatadogLib::Metrics.increment(
      'msign_backend.psre_auto_signing.status',
      tags: %w[status:failed error:true]
    )
  end

  def send_status_psre_success
    DatadogLib::Metrics.increment(
      'msign_backend.status_psre.status',
      tags: %w[status:success error:false]
    )
  end

  def send_status_psre_failed
    DatadogLib::Metrics.increment(
      'msign_backend.status_psre.status',
      tags: %w[status:failed error:true]
    )
  end

  def send_ekyc_status(step, count, tags = [])
    DatadogLib::Metrics.gauge(
      "msign_backend.ekyc_status.#{step}",
      count,
      tags: tags
    )
  end

  def send_gotenberg_success
    DatadogLib::Metrics.increment(
      'msign_backend.gotenberg.hits',
      tags: %w[status:success error:false]
    )
  end

  def send_gotenberg_failed
    DatadogLib::Metrics.increment(
      'msign_backend.gotenberg.errors',
      tags: %w[status:failed error:true]
    )
  end

  def send_gotenberg_elapsed_time(duration)
    DatadogLib::Metrics.gauge(
      'msign_backend.gotenberg.elapsed_time',
      duration,
      tags: %w[status:success error:false]
    )
  end

  def send_envelope_encrypt_signing_failed(status)
    DatadogLib::Metrics.increment(
      "msign_backend.envelope.encrypt_signing.#{status}.status",
      tags: %w[status:failed error:true]
    )
  end

  def send_envelope_encrypt_signing_success(status)
    DatadogLib::Metrics.increment(
      "msign_backend.envelope.encrypt_signing.#{status}.status",
      tags: %w[status:success error:false]
    )
  end
end
# rubocop:enable Metrics/ModuleLength
