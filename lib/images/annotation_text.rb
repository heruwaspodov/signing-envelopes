# frozen_string_literal: true

module Images
  class AnnotationText
    FONT_TYPE = 'Arial'
    FONT_COLOR = 'black'
    FONT_SIZE = 36

    attr_writer :x_off, :y_off, :width, :height, :font_type, :font_size

    def initialize(image_path, string)
      @temp_image_target = Tempfile.new(%w[image_annotate_text .png])
      @image = Magick::Image.read(image_path).first
      @string = string
      @modified_image = @image.clone
    end

    def generate!
      draw
      save
      @temp_image_target
    end

    def x_off
      @x_off.to_f ||= 0.to_f
    end

    def y_off
      @y_off.to_f ||= 0.to_f
    end

    def font_type
      @font_type ||= FONT_TYPE
    end

    def font_size
      @font_size ||= FONT_SIZE
    end

    def width
      @width.to_f ||= 0.to_f
    end

    def height
      @height.to_f ||= 0.to_f
    end

    private

      def draw
        draw = Magick::Draw.new
        draw.font = font_type
        draw.pointsize = font_size
        draw.fill = FONT_COLOR
        draw.gravity = Magick::NorthWestGravity
        draw.annotate(@modified_image, width, height, x_off, y_off, @string)
      end

      def save
        @modified_image.write(@temp_image_target.path)
      end
  end
end
