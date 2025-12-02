# frozen_string_literal: true

module Annotations
  class AnnotationImage < Annotation
    include PdfRotationHelper

    def initialize(document_tempfile, image_tempfile, page_number)
      @document    = document_tempfile
      @image       = image_tempfile
      @page_number = page_number
    end

    def process!
      default_process
      setup_images
      write_files
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
      rotate_val = get_page_rotation(@page)
      @canvas.rotate(rotate_val) do
        @canvas.image(@image.path, at: position_xy_image_rotate90,
                                   width: el_height_rotate, height: el_width_rotate)
      end
    end

    def rotation180
      rotate_val = get_page_rotation(@page)
      @canvas.rotate(rotate_val) do
        @canvas.image(@image.path, at: position_xy_image_rotate180,
                                   width: el_width, height: el_height)
      end
    end

    def rotation270
      rotate_val = get_page_rotation(@page)
      @canvas.rotate(rotate_val) do
        @canvas.image(@image.path, at: position_xy_image_rotate270,
                                   width: el_height_rotate, height: el_width_rotate)
      end
    end
  end
end
