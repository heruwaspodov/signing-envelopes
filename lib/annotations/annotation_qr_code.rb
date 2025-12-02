# frozen_string_literal: true

module Annotations
  class AnnotationQrCode < Annotations::AnnotationImage
    DEFAULT_WIDTH = 15.to_f / 100
    DEFAULT_HEIGHT = 15.to_f / 100
    MARGIN = 1.to_f / 100

    def initialize(document_tempfile, image_tempfile)
      @document = document_tempfile
      @image = image_tempfile
      setup_attributes
    end

    def process!
      default_process
      setup_images
      write_files
      @document
    end

    private

      def setup_attributes
        # reminder : hexa-pdf always start create from bottom left!
        @canvas_w = page_width
        @canvas_h = page_height
        @width = (DEFAULT_WIDTH * @canvas_w.to_f).to_f
        @height = (DEFAULT_HEIGHT * @canvas_w.to_f).to_f
      end

      def default_process
        @file = read_file
        setup_page(@file.pages[last_page - 1])
        setup_canvas
      end

      def last_page
        @page = @file.pages.count
      end

      def no_rotation
        @pos_x = (MARGIN * @canvas_w.to_f).to_f
        @pos_y = (MARGIN * @canvas_w.to_f).to_f

        @canvas.translate(0, 0) do
          @canvas.image(@image.path, at: [@pos_x, @pos_y],
                                     width: @width, height: @height)
        end
      end

      def rotation90
        @pos_x = (MARGIN * @canvas_w.to_f).to_f
        @pos_y = -@canvas_w + (MARGIN * @canvas_w.to_f).to_f
        rotate_val = get_rotation_float(@page)
        @canvas.rotate(rotate_val) do
          @canvas.image(@image.path, at: [@pos_x, @pos_y],
                                     width: @width, height: @height)
        end
      end

      def rotation180
        @pos_x = -@canvas_w + (MARGIN * @canvas_w.to_f).to_f
        @pos_y = -@canvas_h + (MARGIN * @canvas_w.to_f).to_f
        rotate_val = get_rotation_float(@page)
        @canvas.rotate(rotate_val) do
          @canvas.image(@image.path, at: [@pos_x, @pos_y],
                                     width: @width, height: @height)
        end
      end

      def rotation270
        @pos_y = (MARGIN * @canvas_w.to_f).to_f
        @pos_x = -@canvas_h + (MARGIN * @canvas_w.to_f).to_f
        rotate_val = get_rotation_float(@page)
        @canvas.rotate(rotate_val) do
          @canvas.image(@image.path, at: [@pos_x, @pos_y],
                                     width: @width, height: @height)
        end
      end
  end
end
