# frozen_string_literal: true

module Annotations
  class Annotation < ApplicationService
    attr_accessor :document, :image, :text, :path, :canvas, :page, :file,
                  :pos_x, :pos_y, :page_number,
                  :canvas_h, :canvas_w, :font_size, :width, :height

    def read_file
      HexaPDF::Document.open(@document.path)
    end

    def setup_page(page)
      @page = page
    end

    def setup_canvas
      @canvas = @page.canvas(type: :overlay)
    end

    def default_process
      @file = read_file
      setup_page(@file.pages[@page_number.to_i - 1])
      setup_canvas
    end

    def write_files
      @file.write(@document.path, validate: false, optimize: true, incremental: true)
    end

    def page_width
      read_file.pages[@page_number.to_i - 1].box.width
    end

    def page_height
      read_file.pages[@page_number.to_i - 1].box.height
    end

    def setup_attributes(annotation)
      self.font_size = annotation['font_size']
      self.pos_x     = annotation['position_x']
      self.pos_y     = annotation['position_y']
      self.canvas_h  = annotation['canvas_height']
      self.canvas_w  = annotation['canvas_width']
      self.width     = annotation['element_width']
      self.height    = annotation['element_height']
    end

    def ratio_x
      return 1.0 if canvas_w.to_f.zero?

      page_width.to_f / canvas_w
    end

    def ratio_y
      return 1.0 if canvas_h.to_f.zero?

      page_height.to_f / canvas_h
    end

    def el_width
      width.to_f * ratio_x.to_f
    end

    def el_height
      height.to_f * ratio_y.to_f
    end

    def position_x
      pos_x.to_f * ratio_x.to_f
    end

    def position_y
      pos_y.to_f * ratio_y.to_f
    end

    def cropbox_left
      read_file.pages[@page_number.to_i - 1][:CropBox]&.value&.[](0) || 0
    end

    def cropbox_bottom
      read_file.pages[@page_number.to_i - 1][:CropBox]&.value&.[](1) || 0
    end

    def adj_position_xy
      return position_xy unless Flipper.enabled? :ft_annotation_cropbox

      x, y = position_xy
      [x + cropbox_left, y + cropbox_bottom]
    end

    def position_xy
      [position_x, page_height - position_y - el_height]
    end

    # rotate
    def ratio_x_rotate
      return 1.0 if canvas_h.to_f.zero?

      page_width.to_f / canvas_h
    end

    def ratio_y_rotate
      return 1.0 if canvas_w.to_f.zero?

      page_height.to_f / canvas_w
    end

    def el_width_rotate
      height.to_f * ratio_y_rotate.to_f
    end

    def el_height_rotate
      width.to_f * ratio_x_rotate.to_f
    end

    def position_x_rotate
      pos_y.to_f * ratio_y_rotate.to_f
    end

    def position_y_rotate
      pos_x.to_f * ratio_x_rotate.to_f
    end

    def position_xy_text_rotate90
      [position_y_rotate, - position_x_rotate - @font_size]
    end

    def position_xy_text_rotate180
      [position_x - page_width, - position_y - @font_size]
    end

    def position_xy_text_rotate270
      [-page_height + position_y_rotate, page_width - position_x_rotate - @font_size]
    end

    def position_xy_image_rotate90
      [position_y_rotate, - position_x_rotate - el_width_rotate]
    end

    def position_xy_image_rotate180
      [position_x - page_width, - position_y - el_height]
    end

    def position_xy_image_rotate270
      [-page_height + position_y_rotate, page_width - position_x_rotate - el_width_rotate]
    end

    def process!; end
  end
end
