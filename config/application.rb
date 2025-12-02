# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ESign
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.autoload_paths << Rails.root.join('lib')

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore
    config.session_store :cookie_store

    config.i18n.available_locales = %i[en id]

    # set default active job queue to sidekiq
    config.active_job.queue_adapter = :sidekiq

    if Rails.env.test?
      # set active job queue adaptor to test when doing test
      config.active_job.queue_adapter = :test
    end

    config.app = config_for(:app)
    config.exceptions_app = routes
  end
end
