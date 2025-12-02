# frozen_string_literal: true

# Facade pattern for storage services
module EsignStorage
  class Storage
    attr_reader :client

    # This method initializes a new Storage object
    # that uses the specified service
    #
    # @param service [String] the service to use
    # @param options [Hash] the options to create the service with
    def initialize(service = nil, options = {})
      @service = service
      @options = options

      set_client
    rescue NoMethodError
      raise 'Unsupported service'
    end

    private

      # This method sets the client based on the service
      def set_client
        __send__("#{active_storage_client}_client")
      end

      def active_storage_client
        return @service if @service.present?

        Rails.application.config.active_storage.service
      end

      # Create an OSS client.
      def aliyun_client
        @client = EsignStorage::Aliyun.new
      end

      # Creates an S3 client with the specified options.
      # The client uses the default credentials provider chain.
      def amazon_client
        @client = EsignStorage::Amazon.new
      end
  end
end
