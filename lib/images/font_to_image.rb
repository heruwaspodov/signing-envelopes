# frozen_string_literal: true

module Images
  class FontToImage
    FONT_SIZE = 72
    FONT_WIDTH = 40
    FONT_HEIGHT = 81

    attr_writer :width, :height, :size, :color

    def initialize(type: nil, text: '')
      @temp_image_target = Tempfile.new(%w[font_to_image .png])
      @text = text
      @type = type
    end

    def generate!
      draw
      save
      @temp_image_target
    end

    def size
      @size ||= FONT_SIZE
    end

    def width
      @width ||= calculate_text_width.to_f
    end

    def height
      @height ||= calculate_text_height.to_f
    end

    def color
      @color ||= 'black'
    end

    private

      def calculate_text_width
        metrics = Magick::Draw.new
        metrics.font = @type if @type.present?
        metrics.pointsize = size
        metrics.get_type_metrics(@text).width
      end

      def calculate_text_height
        metrics = Magick::Draw.new
        metrics.font = @type if @type.present?
        metrics.pointsize = size
        metrics.get_type_metrics(@text).height
      end

      def background_image
        Magick::Image.new(calculate_text_width, calculate_text_height) do |img|
          img.background_color = 'transparent' # Set the background to transparent
        end
      end

      def draw
        @image = background_image

        # Create a drawing context
        draw = Magick::Draw.new
        draw.font = @type if @type.present?
        draw.pointsize = size
        draw.gravity = Magick::CenterGravity
        draw.fill = color

        # Add text to the image
        draw.text(0, 0, @text)

        # Annotate the image with the text
        draw.draw(@image)

        @image.format = 'PNG'
      end

      def save
        @image.write(@temp_image_target.path)
      end
  end
end
