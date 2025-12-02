# frozen_string_literal: true

module CloudHsmLoader
  class << self
    # rubocop:disable Metrics/AbcSize
    def load_engine!
      # First ensure cleanup of any existing engines
      OpenSSL::Engine.cleanup

      # Force GC to clean up any lingering references
      GC.start

      # Load the engine
      OpenSSL::Engine.load

      # Get the CloudHSM engine
      engine_type = Rails.application.config.cloud_hsm.current_config.engine
      engine = OpenSSL::Engine.by_id(engine_type)

      if engine
        # Set it as default for all crypto operations
        engine.set_default(OpenSSL::Engine::METHOD_RSA)
        Rails.logger.info "CloudHSM engine loaded successfully using: #{engine_type}"

      else
        Rails.logger.error "Failed to load CloudHSM #{engine_type} engine"
      end

      engine
    rescue StandardError => e
      Rails.logger.error "Error loading CloudHSM engine: #{e.message}"
      nil
    end
        # rubocop:enable Metrics/AbcSize
      end
end

# Load the engine during initialization
Rails.application.config.after_initialize do
  CloudHsmLoader.load_engine!
end

# Cleanup on application shutdown
at_exit do
  OpenSSL::Engine.cleanup
end
