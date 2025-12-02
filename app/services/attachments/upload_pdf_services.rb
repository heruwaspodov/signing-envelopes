# frozen_string_literal: true

module Attachments
  require 'libreconv'

  # rubocop:disable Metrics/ClassLength
  class UploadPdfServices
    include UploadPathHelper
    include DatadogMetricHelper
    include PdfRotationHelper
    attr_reader :file, :envelope

    class FailedUploadError < StandardError; end

    def initialize(file, envelope)
      @file = Files::FileValidation.new(file)
      @envelope = envelope
    end

    def mime_type
      @file.mime_type
    end

    def attach!
      execute_by_mime
      attach_file if execute_by_mime.present?
    rescue HexaPDF::MalformedPDFError
      raise FailedUploadError
    ensure
      tempfile_target.close
      @file.tempfile.close
    end

    def attach_signed!
      execute_by_mime
      attach_file_signed if execute_by_mime.present?
    ensure
      tempfile_target.close
      @file.tempfile.close
    end

    def tempfile_target
      Tempfile.new([@envelope.filename, '.pdf'])
    end

    def execute_by_mime
      return @execute_by_mime ||= file_doc if Envelopes::DocumentValidation::SUPPORTED_DOC.include?(mime_type)

      return @execute_by_mime ||= file_image if Files::ImageValidation::SUPPORTED_FILETYPE.include?(mime_type)

      @execute_by_mime ||= file_pdf
    end

    def file_doc
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      conversion = convert_doc_process
      finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      result = start - finish

      tracking_name = 'doc_converted'
      tracking_name += '_with_external_srv' if Flipper.enabled? :ft_doc_to_pdf_service,
                                                                @envelope.user
      send_envelope_elapsed_time(result, tracking_name)

      conversion
    end

    def convert_doc_process
      return convert_with_go if Flipper.enabled? :ft_doc_to_pdf_service, @envelope.user

      if Flipper.enabled? :ft_doc_to_pdf_gotenberg, @envelope.user
        Attachments::FromDocServicesV2.new(@file, tempfile_target).exec!
      else
        Attachments::FromDocServices.new(@file, tempfile_target).exec!
      end
    end

    def convert_with_go
      copy_to_shared_folder
      response = Requests::Sender.new >> Requests::Payloads::Go::ConvertDocToPdf.new(input_path)
      response = response['response'].with_indifferent_access

      Log.info('ConvertDocWithGo', { request: input_path, response: response })

      validate_response(response)

      file_path = process_file(response['data']['file_path'])

      File.open(file_path)
    end

    def process_file(path)
      raise Go::Errors::Error, I18n.t('error.validation.object_not_found', params: path) unless File.exist?(path)

      loop do
        break unless File.size(path).zero?

        puts "#{filename} is empty. Retrying in 2 seconds..."
        sleep 2
      end

      path
    rescue StandardError => e
      raise Go::Errors::Error, e.message
    end

    def copy_to_shared_folder
      FileUtils.cp(@file.tempfile.path, input_path)
    end

    def input_path
      @uniq_filename ||= "#{@envelope.id[0..7]}_#{Time.now.to_i}_#{@envelope.filename}"
      @input_path ||= "#{ENV['SHARED_VOLUME_PATH']}/input/#{@uniq_filename}"
    end

    def validate_response(response)
      errors = response['errors']
      converted_data = response.dig('data', 'file_path')

      return true unless errors.present? || converted_data.nil?

      raise Go::Errors::Error, I18n.t('error.attachments.convert_failure', code: response['code'])
    end

    def file_image
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      conversion = Attachments::FromImgServices.new(@file,
                                                    tempfile_target).exec!
      finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result = start - finish
      send_envelope_elapsed_time(result, 'image_converted')

      conversion
    end

    def file_pdf
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      conversion = Attachments::FromPdfServices.new(@file,
                                                    tempfile_target).exec!
      finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result = start - finish
      send_envelope_elapsed_time(result, 'pdf_converted')

      conversion
    end

    def filename
      if File.extname(@envelope.filename) == '.pdf'
        @envelope.filename
      else
        "#{File.basename(@envelope.filename,
                         File.extname(@envelope.filename))}.pdf"
      end
    end

    def attach_file
      tempfile = force_pdf
      @envelope.doc = create_blob(tempfile)
      @envelope.save!

      # this service used by both envelope upload and template upload
      # the extract metadata is only for envelope upload
      process_extract_metadata(tempfile)
      generate_thumbnail if Flipper.enabled?(:ft_document_thumbnail, @envelope.user)

      FileUtils.rm_f(tempfile.path)
    end

    def create_blob(tempfile)
      if Flipper.enabled?(:ft_change_upload_path, @envelope.user)
        create_blob_from_file(@envelope, tempfile, 'docs', filename)
      else
        ActiveStorage::Blob.create_and_upload!(
          io: tempfile,
          filename: filename,
          content_type: 'application/pdf'
        )
      end
    end

    def process_extract_metadata(tempfile)
      return unless @envelope.is_a?(Envelope)

      if Flipper.enabled?(:ft_async_extract_metadata, @envelope.user)
        @envelope.trigger_extract_and_store_metadata!
      else
        extract_and_store_metadata(tempfile)
      end
    end

    def generate_thumbnail
      Envelopes::GenerateThumbnailWorker.perform_async(@envelope.id)
    end

    def extract_and_store_metadata(tempfile)
      pdf_metadata = extract_pdf_metadata(tempfile)

      @envelope.update!(pdf_metadata: pdf_metadata.to_json)
    end

    def extract_pdf_metadata(tempfile)
      pdf = HexaPDF::Document.open(tempfile.path)

      {
        filesize: tempfile.size,
        total_pages: pdf.pages.count,
        pages: get_pdf_pages(pdf)
      }
    end

    def get_pdf_pages(pdf)
      pdf.pages.map.with_index do |page, index|
        {
          page: index + 1,
          rotation: get_page_rotation(page),
          orientation: page.orientation,
          width: page.box.width,
          height: page.box.height
        }
      end
    end

    def force_pdf
      @envelope.try(:is_certified).to_bool ? File.open(execute_by_mime.path) : hexapdf
    end

    def attach_file_signed
      blob = if Flipper.enabled?(:ft_change_upload_path, @envelope.user)
               create_blob_from_file(@envelope, execute_by_mime, 'signed_docs', filename)
             else
               ActiveStorage::Blob.create_and_upload!(
                 io: execute_by_mime,
                 filename: filename,
                 content_type: 'application/pdf'
               )
             end

      @envelope.signed_doc = blob
      @envelope.save!

      @envelope.trigger_extract_and_store_metadata! if @envelope.is_a? Envelope
      generate_thumbnail if Flipper.enabled?(:ft_document_thumbnail, @envelope.user)
    end

    def hexapdf
      pdf = HexaPDF::Document.open(execute_by_mime.path)
      new_pdf = HexaPDF::Document.new
      filename = Rails.root.join('tmp', "#{@envelope.id}.pdf")

      pdf.pages.each { |page| new_pdf.pages << new_pdf.import(page) }

      # https://github.com/gettalong/hexapdf/issues/30
      # https://hexapdf.gettalong.org/examples/optimizing.html
      # Adding `validate: false` as a workaround for the HexaPDF error:
      # Validation error: Required field BaseFont is not set

      new_pdf.task(:optimize, compact: true, object_streams: :generate,
                              compress_pages: false)
      new_pdf.write(filename.to_s, validate: false, optimize: true, incremental: true)
      File.open(filename)
    end
  end
  # rubocop:enable Metrics/ClassLength
end
