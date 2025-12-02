# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  sidekiq_options retry: 25
end
