# frozen_string_literal: true

module Attachments
  class MultipleConvertToPdfServices < ApplicationService
    def initialize(files = [])
      @files = files
    end

    def call
      convert_files
    end

    private

      def convert_files
        @files.map do |file|
          next unless file.is_need_convert

          tempfile_target = Tempfile.new([file.meta_doc.filename, '.pdf'])

          if Envelopes::DocumentValidation::SUPPORTED_DOC.include?(file.meta_doc.mime_type)
            Attachments::FromDocServices.new(file, tempfile_target).exec!
          elsif Files::ImageValidation::SUPPORTED_FILETYPE.include?(file.meta_doc.mime_type)
            Attachments::FromImgServices.new(file, tempfile_target).exec!
          end

          file.tempfile = tempfile_target
        end
      end
  end
end
