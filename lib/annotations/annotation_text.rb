# frozen_string_literal: true

module Annotations
  class AnnotationText < Annotation
    include PdfRotationHelper

    def initialize(document_tempfile, text, page_number)
      @document    = document_tempfile
      @text        = text
      @page_number = page_number
    end

    def process!
      default_process
      setup_text
      write_files
    end

    def setup_text
      rotate_value = get_page_rotation(@page)
      no_rotation if [nil, 0, 360, -360].include?(rotate_value)
      rotation90 if [90, -270].include?(rotate_value)
      rotation180 if [180, -180].include?(rotate_value)
      rotation270 if [270, -90].include?(rotate_value)
    end

    def no_rotation
      @canvas.fill_color(0, 0, 0)
             .font(font_file, size: @font_size.to_i - 3) # calibrated with FE side
             .text(@text, at: position_xy)
    end

    def rotation90
      @canvas.fill_color(0, 0, 0).rotate(get_page_rotation(@page))
             .font(font_file, size: @font_size.to_i - 3) # calibrated with FE side
             .text(@text, at: position_xy_text_rotate90)
    end

    def rotation180
      @canvas.fill_color(0, 0, 0).rotate(get_page_rotation(@page))
             .font(font_file, size: @font_size.to_i - 3) # calibrated with FE side
             .text(@text, at: position_xy_text_rotate180)
    end

    def rotation270
      @canvas.fill_color(0, 0, 0).rotate(get_page_rotation(@page))
             .font(font_file, size: @font_size.to_i - 3) # calibrated with FE side
             .text(@text, at: position_xy_text_rotate270)
    end

    def el_height
      @font_size.to_f # for text, element height is based on font size
    end

    private

      def font_file
        File.open('fonts/Inter-Regular.ttf') || 'Helvetica'
      end
  end
end
