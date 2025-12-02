# frozen_string_literal: true

module Attachments
  class UploadMergingTemplateServices < ApplicationService
    include UploadPathHelper
    include PdfRotationHelper
    attr_reader :files, :envelope

    FILE = Struct.new(:file, :is_need_convert, :meta_doc, :tempfile)
    META_DOCUMENT = Struct.new(:filename, :mime_type, :filesize, :total_pages)
    PDF_META_DATA = Struct.new(:filesize, :total_pages, :pages, :list_documents)

    class FailedUploadError < StandardError; end

    def initialize(files, template)
      @files = files.map do |f|
        # define file validation
        file = Files::FileValidation.new(f)

        # flagging convert
        is_need_convert = !Envelopes::DocumentValidation::SUPPORTED_PDF.include?(file.mime_type)

        # save metadata
        meta_doc = setup_meta(file)

        # tempfile
        tempfile = file.tempfile

        # return file
        FILE.new(file, is_need_convert, meta_doc, tempfile)
      end
      @template = template
    end

    def call
      convert if need_convert?
      merge
      update_meta_files
      update_meta_pdf
      attach_file
    rescue HexaPDF::MalformedPDFError
      raise FailedUploadError
    ensure
      @files.pluck(:tempfile).each(&:close)
      merge.close
    end

    private

      def attach_file
        blob = if Flipper.enabled?(:ft_change_upload_path, @template.user)
                 create_blob_from_file(@template, merge, 'docs', "#{@template.id}.pdf")
               else
                 ActiveStorage::Blob.create_and_upload!(
                   io: merge,
                   filename: "#{@template.id}.pdf",
                   content_type: 'application/pdf'
                 )
               end

        @template.doc = blob
        @template.save!
      end

      def merge
        @merge ||= PdfMerging.new(@files.pluck(:tempfile)).call
      end

      def update_meta_files
        @files.map do |file|
          read_file = HexaPDF::Document.open(file.tempfile)
          file.meta_doc.total_pages = read_file.pages.count
        end
      end

      def update_meta_pdf
        pdf = HexaPDF::Document.open(merge.path)
        meta = PDF_META_DATA.new(merge.size, pdf.pages.count, get_pdf_pages(pdf),
                                 @files.pluck(:meta_doc))

        @template.pdf_metadata = meta
        @template.save
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

      def convert
        Attachments::MultipleConvertToPdfServices.new(@files).call
      end

      def need_convert?
        @files.pluck(:is_need_convert).include? true
      end

      def setup_meta(file)
        filename = file.try(:file).try(:original_filename)
        mime_type = file.mime_type
        filesize = file.filesize
        META_DOCUMENT.new(filename, mime_type, filesize, 0)
      end
  end
end
