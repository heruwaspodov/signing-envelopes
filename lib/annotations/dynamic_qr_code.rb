# frozen_string_literal: true

module Annotations
  class DynamicQrCode < Annotations::AnnotationImage
    def initialize(document_tempfile, image_tempfile, qr_code_annotation)
      @document = document_tempfile
      @image = image_tempfile
      @qr_code_annotation = qr_code_annotation
      @page_number = qr_code_annotation['page']
    end

    def call!
      setup_attributes(@qr_code_annotation)
      process!
      @document
    end
  end
end
