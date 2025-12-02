# frozen_string_literal: false

module Certifications
  require 'openssl'
  require_relative '../app_config'

  class Cert
    MAX_RETRY_ATTEMPT = 3

    include Helper
    include DatadogMetricHelper

    attr_accessor :document, :output_path, :output_file, :engine, :cert_reason,
                  :cert_location, :cert_contact
    attr_reader :dss, :success

    def initialize(file, envelope_id)
      @document      = HexaPDF::Document.open(file.path)
      @envelope      = Envelope.find(envelope_id)
      @output_path   = "tmp/#{envelope_id}-#{SecureRandom.uuid}-signed.pdf"
      @cert_location = AppConfig.cert_location
      @cert_contact  = AppConfig.cert_contact
      @dss           = Certifications::DocumentSecurityStore.new(envelope_id)
      @config        = Rails.application.config.cloud_hsm.current_config
      @success       = false
    end

    def cert!
      process_certificate!
      add_ltv!
      set_output_file!
    end

    def set_output_file!
      @output_file = File.open(@output_path)
    end

    def cleanup!
      File.delete(@output_path) if File.exist?(@output_path)
    end

    def process_certificate!
      return if certificate_attached?

      signing
      @envelope.update!(aatl_cert: true)
    rescue StandardError => e
      retry if attempts < MAX_RETRY_ATTEMPT

      # when retry exhausted, capture to papertrail, sentry, or maybe google chat notif or modpnal
      @envelope.update!(aatl_cert: false)
      Rails.logger.error "Error adding cert id: #{@envelope.id} to #{@output_path}: #{e.inspect}"
    end

    def signing
      time_start = Time.now
      Log.info(">> start signing (env: #{@envelope.id}) at #{time_start}", {})

      sign_document!

      time_end = Time.now
      Log.info(">> finish signing (env: #{@envelope.id}) at #{time_end}", {})
      Log.info(
        ">> success signing (env: #{@envelope.id}) in #{(time_end - time_start).to_f} seconds", {}
      )
    end

    def sign_document!
      @document.sign(
        @output_path,
        signature_type: :pades,
        signature_size: AppConfig.cert_signature_size,
        timestamp_handler: ts_handler,
        certificate: msign_cert,
        key: private_key,
        certificate_chain: [intermediate1_cert, intermediate2_cert],
        reason: reason_with_signers,
        location: @cert_location,
        contact_info: @cert_contact,
        write_options: write_options
      )
    end

    def add_ltv!
      start_time = Time.now

      if @dss.add_ltv(@output_path)
        duration = (Time.now - start_time).to_f

        @envelope.update!(ltv_cert: true)
        send_add_ltv_duration((duration * 1000).to_i)

        # mark as success
        @success = true
      else
        @envelope.update!(ltv_cert: false)
        send_add_ltv_errors({ reason: :invalid_doc })
      end
    rescue StandardError => e
      @envelope.update!(ltv_cert: false)
      handle_add_ltv_error(e)
    ensure
      send_add_ltv_hits
    end

    def handle_add_ltv_error(err)
      prefix_string = "[AddLTV] envelope_id:#{@envelope_id}"
      Rails.logger.error "#{prefix_string} - Error adding LTV to #{@output_path}: #{err.inspect}"
      file_path = File.expand_path(__FILE__)
      Alert::NotifyErrorAlertJob.perform_later "Failed: add LTV envelope_id: #{@envelope.id}" \
                                               "\nwith message: #{err}" \
                                               "\nFile: #{file_path}"

      send_add_ltv_errors({ reason: :runtime_error })
    end

    def private_key
      if Rails.env.test? || Rails.env.development?
        @private_key ||= HexaPDF.demo_cert.key
        return @private_key
      end

      @private_key ||= OpenSSL::PKey::RSA.new(File.read(private_key_path))
    end

    def private_key_path
      @config.private_key
    end

    def msign_cert
      if Rails.env.test? || Rails.env.development?
        @msign_cert ||= HexaPDF.demo_cert.cert
        return @msign_cert
      end

      @msign_cert ||= x509_certificate(public_key_path)
    end

    def public_key_path
      @config.cert
    end

    def intermediate1_cert
      if Rails.env.test? || Rails.env.development?
        @intermediate1_cert ||= HexaPDF.demo_cert.sub_ca
        return @intermediate1_cert
      end

      @intermediate1_cert ||= x509_certificate(intermediate1_cert_path)
    end

    def intermediate1_cert_path
      @config.intermediate1
    end

    def intermediate2_cert
      if Rails.env.test? || Rails.env.development?
        @intermediate2_cert ||= HexaPDF.demo_cert.root_ca
        return @intermediate2_cert
      end

      @intermediate2_cert ||= x509_certificate(intermediate2_cert_path)
    end

    def intermediate2_cert_path
      @config.intermediate2
    end

    private

      def attempts
        @attempts ||= 0
        @attempts += 1
      end

      def write_options
        {
          validate: false
        }
      end

      def ts_handler
        return nil if Rails.env.test? || Rails.env.development?

        @document.signatures.signing_handler(
          name: :timestamp,
          tsa_url: AppConfig.tsa_url
        )
      end

      def reason_with_signers
        reason = AppConfig.cert_reason
        reason += "\n\nSigners :\n#{@envelope.signers.map(&:email).join("\n")}" if @envelope.try(:signers).present?
        reason
      end

      def certificate_attached?
        @document.signatures.find do |signature|
          ['mekari', 'pt mid solusi nusantara'].include?(signature.signer_name.downcase)
        end.present?
      end
  end
end
