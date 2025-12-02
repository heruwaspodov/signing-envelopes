# frozen_string_literal: true

module Annotations
  class AnnotationSignature < Annotation
    require 'hexapdf'
    require "#{HexaPDF.data_dir}/cert/demo_cert.rb"
    require_relative '../app_config'

    include Certifications::Helper
    include Annotations::SignatureRotations::NoRotation
    include Annotations::SignatureRotations::Rotation180
    include Annotations::SignatureRotations::Rotation90
    include Annotations::SignatureRotations::Rotation270

    attr_accessor :recipient
    attr_reader :dss

    MAX_RETRY_ATTEMPT = 3
    DELAY = 0.2

    def initialize(document_tempfile, image_tempfile, page_number)
      @document = document_tempfile
      @image_path = image_tempfile

      @doc = HexaPDF::Document.open(@document.path)
      @page = @doc.pages[page_number.to_i - 1]
      @page_number = page_number

      @cert_location = AppConfig.cert_location
      @cert_contact  = AppConfig.cert_contact
      @attempts = 1

      @config = Rails.application.config.cloud_hsm.current_config
    end

    def rotate_value
      @rotate_value ||= @page.value[:Rotate].to_i
    rescue StandardError
      0
    end

    def setup_image_rotation
      case rotate_value
      when 90, -270 then rotation90
      when 180, -180 then rotation180
      when 270, -90 then rotation270
      else
        no_rotation
      end
    end

    def setup_dss(envelope_id)
      @dss = Certifications::DocumentSecurityStore.new(envelope_id)
    end

    def process!
      setup_image_rotation
      signing
      add_ltv!
      @document
    rescue StandardError => e
      if (@attempts += 1) <= MAX_RETRY_ATTEMPT
        sleep(DELAY)
        retry
      end

      raise e
    end

    def signing
      time_start = Time.now
      Log.info(">> start signing (rec: #{@recipient.id}) at #{time_start}", {})
      sign
      time_end = Time.now
      Log.info(">> finish signing (rec: #{@recipient.id}) at #{time_end}", {})
      Log.info(
        ">> success signing (rec: #{@recipient.id}) in #{(time_end - time_start).to_f} seconds", {}
      )
    end

    def sign
      @doc.sign(@document.path, reason: reason,
                                location: @cert_location,
                                contact_info: @cert_contact,
                                signature: field_signature,
                                certificate: msign_cert,
                                key: private_key,
                                certificate_chain: [intermediate1_cert, intermediate2_cert],
                                write_options: write_options,
                                signature_type: :pades,
                                signature_size: AppConfig.cert_signature_size,
                                timestamp_handler: ts_handler)
    end

    def image_signature
      @image_signature ||= @doc.images.add(@image_path)
    end

    def field_signature
      field = create_field(name)
      init_widget = create_widget(field)
      widget = rotate_content_widget(init_widget)
      widget.xobject(image_signature,
                     at: [0, 0],
                     width: @widget_width,
                     height: @widget_height)
      field
    end

    def add_ltv!
      @dss.add_ltv(@document.path)
    end

    def name
      "#{@recipient.email}#{SecureRandom.hex(5)}"
    end

    def create_field(name)
      @doc.acro_form(create: true).create_signature_field(name)
    end

    def create_widget(field)
      field.create_widget(@page, defaults: false, Rect: @matrix_coordinate)
    end

    def rotate_content_widget(widget)
      widget_obj = widget.create_appearance.canvas

      rotate_options(widget_obj)
    end

    def rotate_options(widget)
      case rotate_value
      when 90, -270 then rotate_content90(widget)
      when 180, -180 then rotate_content180(widget)
      when 270, -90 then rotate_content270(widget)
      else
        widget
      end
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

    def write_options
      {
        validate: false
      }
    end

    def ts_handler
      return nil if Rails.env.test? || Rails.env.development?

      @doc.signatures.signing_handler(
        name: :timestamp,
        tsa_url: AppConfig.tsa_url
      )
    end

    def reason
      "#{AppConfig.cert_reason}\n\nSigners :\n#{@recipient.email}"
    end
  end
end
