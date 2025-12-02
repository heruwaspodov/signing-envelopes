# frozen_string_literal: true

module Annotations
  module V2
    # NOTE: The v2 version read and write file only once during setup annotations
    class AnnotationImage < Annotation
      include PdfRotationHelper

      SUPPORTED_ANNOTATION = %w[
        signature initial stamp
      ].freeze

      def initialize(document_tempfile, image_params, annotations)
        @document = document_tempfile
        @image_params = image_params
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

        def setup_annotations
          return if @annotations.blank?

          @annotations.each do |annotation|
            define_page_number(annotation['page'])
            define_image(annotation['type_of'])

            setup_attributes(annotation)
            setup_page(file.pages[@page_number.to_i - 1])
            next if @page.nil?

            setup_canvas
            setup_images
          end
        end

        def define_page_number(page_number)
          @page_number = page_number
        end

        def define_image(type_of)
          @image = case type_of
                   when 'signature'
                     signature_image
                   when 'initial'
                     initial_image
                   else
                     stamp_image
                   end
        end

        def write_file
          file.write(@document.path, validate: false, optimize: true, incremental: true)
        end

        def setup_images
          rotate_val = get_page_rotation(@page)
          no_rotation if [0, 360, -360].include?(rotate_val)
          rotation90 if [90, -270].include?(rotate_val)
          rotation180 if [180, -180].include?(rotate_val)
          rotation270 if [270, -90].include?(rotate_val)
        end

        def no_rotation
          @canvas.translate(0, 0) do
            @canvas.image(@image.path, at: position_xy,
                                       width: el_width, height: el_height)
          end
        end

        def rotation90
          @canvas.rotate(get_page_rotation(@page)) do
            @canvas.image(@image.path, at: position_xy_image_rotate90,
                                       width: el_height_rotate, height: el_width_rotate)
          end
        end

        def rotation180
          @canvas.rotate(get_page_rotation(@page)) do
            @canvas.image(@image.path, at: position_xy_image_rotate180,
                                       width: el_width, height: el_height)
          end
        end

        def rotation270
          @canvas.rotate(get_page_rotation(@page)) do
            @canvas.image(@image.path, at: position_xy_image_rotate270,
                                       width: el_height_rotate, height: el_width_rotate)
          end
        end

        def signature_image
          @signature_image ||= @image_params.signature
        end

        def initial_image
          @initial_image ||= @image_params.initial
        end

        def stamp_image
          @stamp_image ||= @image_params.stamp
        end
    end
  end
end
