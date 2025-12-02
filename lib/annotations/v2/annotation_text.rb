# frozen_string_literal: true

module Annotations
  module V2
    # NOTE: The v2 version read and write file only once during setup annotations
    class AnnotationText < Annotation
      include PdfRotationHelper

      SUPPORTED_ANNOTATION = %w[
        date_signed name email company job_title address
      ].freeze

      def initialize(document_tempfile, text_params, annotations)
        @document = document_tempfile
        @text_params = text_params
        @annotations = annotations
      end

      def call
        setup_annotations
        write_file
      end

      private

        def file
          @file ||= HexaPDF::Document.open(@document.path)
        end

        # rubocop:disable Metrics/AbcSize
        def setup_annotations
          return if @annotations.blank?

          @annotations.each do |annotation|
            define_page_number(annotation['page'])
            define_text(annotation['type_of'], annotation['value'])

            setup_attributes(annotation)
            setup_page(file.pages[@page_number.to_i - 1])
            next if @page.nil?

            setup_canvas
            setup_text
          end
        end
        # rubocop:enable Metrics/AbcSize

        def define_page_number(page_number)
          @page_number = page_number
        end

        def define_text(type_of, value = nil)
          @text = value.present? ? value : @text_params[type_of.to_sym]
        end

        def write_file
          file.write(@document.path, validate: false, optimize: true, incremental: true)
        end

        def setup_text
          rotate_val = get_page_rotation(@page)
          no_rotation if [nil, 0, 360, -360].include?(rotate_val)
          rotation90 if [90, -270].include?(rotate_val)
          rotation180 if [180, -180].include?(rotate_val)
          rotation270 if [270, -90].include?(rotate_val)
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

        def font_file
          @font_file ||= File.open('fonts/Inter-Regular.ttf') || 'Helvetica'
        end
    end
  end
end
