# frozen_string_literal: true

module Files
  class FileValidation
    attr_accessor :file, :any_password

    def initialize(file)
      @file = if file.is_a?(String)
                convert_to_file(file)
              else
                file
              end

      @any_password = false
      @filter_error = false
      @malformed = false

      raise I18n.t('error.validation.image_not_readable') unless @file
    end

    def types
      supported_document = ::Envelopes::DocumentValidation::SUPPORTED_FILETYPE
      supported_image = ::Files::ImageValidation::SUPPORTED_FILETYPE

      supported_document + supported_image
    end

    def valid?
      @file.present? ? (types.include? mime_type) : false
    end

    def tempfile
      @tempfile ||= @file.tempfile
    rescue NoMethodError
      @tempfile ||= @file
    end

    def read_file
      return nil unless mime_type == 'application/pdf'

      @read_file ||= HexaPDF::Document.open(@file.tempfile)
    rescue HexaPDF::EncryptionError
      @any_password = true
      nil
    rescue HexaPDF::FilterError
      @filter_error = true
      nil
    rescue HexaPDF::MalformedPDFError
      @malformed = true
      nil
    end

    def filter_error?
      @filter_error
    end

    def malformed?
      @malformed
    end

    def any_password?
      read_file
      @any_password
    end

    def any_certificate?
      return false if read_file.nil?

      read_file.signed?
    end

    def any_protection?
      return false if read_file.nil?

      read_file.encrypted?
    end

    def filename
      @filename = @file.tempfile
    end

    def mime_type
      @mime_type ||= processed_mime
    end

    def processed_mime
      raw_type = FileMagic.new(FileMagic::MAGIC_MIME).file(tempfile.path, true)
      mime = raw_type.to_s.split(';').first.strip

      return mime unless ['application/octet-stream', 'application/zip'].include?(mime)

      infer_mime_from_extension
    end

    def infer_mime_from_extension
      file_name = if @file.respond_to?(:original_filename)
                    @file.original_filename
                  elsif @file.respond_to?(:path)
                    @file.path
                  else
                    @file.tempfile.path
                  end

      ext = File.extname(file_name).downcase
      {
        '.docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      }[ext] || 'application/octet-stream'
    end

    def filesize
      tempfile.size
    end

    def to_base64
      return nil unless valid?

      "data:#{mime_type};base64," + Base64.strict_encode64(File.read(tempfile))
    end

    def convert_to_file(image_base64)
      temp_image = Tempfile.new('validate_image')

      image_base64 = image_base64.split(',')[1] if image_base64.start_with?('data:')

      tempfile_return(temp_image, image_base64)
    rescue StandardError => e
      Rails.logger.error e.message
      nil
    end

    def tempfile_return(temp_image, image_base64)
      File.binwrite(temp_image.path, Base64.decode64(image_base64))

      temp_file = Struct.new(:tempfile, :filename)
      temp_file.new(temp_image, nil)
    end

    def valid_size?
      @file.size.to_i <= file_size_limit.to_i
    end

    def valid_attachment_size?
      @file.size.to_i <= attachment_size_limit.to_i
    end

    def valid_signature_size?
      tempfile.size.to_i <= attachment_signature_limit.to_i
    end

    def allowed_docmdp_level?
      return false if read_file.nil?

      level = docmdp_level(read_file.signatures.first)

      Envelope::ALLOWED_DOCMDP_LEVEL.include? level.to_i
    end

    def docmdp_level(signature)
      perms = Envelope::DEFAULT_DOCMDP_LEVEL
      sigref = reference_signature(signature)
      if sigref && signature.document.catalog[:Perms]&.[](:DocMDP) == signature
        perms = sigref[:TransformParams]&.[](:P) || 2
      end

      perms
    end

    def reference_signature(signature)
      return unless signature.present?

      signature[:Reference]&.find { |ref| ref[:TransformMethod] == :DocMDP }
    end

    def file_size_limit
      Configs::ConfigServices.new.file_size_limit.to_i.megabytes
    end

    def attachment_size_limit
      Configs::ConfigServices.new.approval_request_max_attachment_size.to_i.megabytes
    end

    def attachment_signature_limit
      Configs::ConfigServices.new.signature_image_size_limit.to_i.megabytes
    end
  end
end
