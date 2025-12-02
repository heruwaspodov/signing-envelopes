# frozen_string_literal: true

class SchedulerMiddleware
  def call(_worker_instance, job, queue)
    if queue == 'scheduler'
      worker_name = job['class'].split('::').last.underscore

      datadog_tracking_increment(worker_name)

      yield

      datadog_tracking_decrement(worker_name)
    else
      yield
    end
  end

  def datadog_tracking_increment(worker_name)
    Rails.logger.info "msign_backend.scheduler.#{worker_name} started"
    DatadogLib::Metrics.increment(
      "msign_backend.scheduler.#{worker_name}.hits"
    )
  end

  def datadog_tracking_decrement(worker_name)
    Rails.logger.info "msign_backend.scheduler.#{worker_name} finished"
    DatadogLib::Metrics.decrement(
      "msign_backend.scheduler.#{worker_name}.hits"
    )
  end
end
