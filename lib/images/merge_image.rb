# frozen_string_literal: true

module Images
  class MergeImage
    X_OFF_RATIO = 0.12
    Y_OFF_RATIO = 0.15
    QR_Y_OFF_RATIO = 0.17
    UUID_RATIO = 0.15
    DEFAULT_SIZE = 500

    attr_accessor :image
    attr_writer :x_off, :x_off_ratio, :y_off, :y_off_ratio, :width, :height, :image_width,
                :image_height, :resized_base_image, :resized_image, :gravity
    attr_reader :base_image

    def initialize(base_image_path, image_path)
      @temp_image_target = Tempfile.new(%w[image_merge .png])
      @base_image = Magick::Image.read(base_image_path).first
      @image = Magick::Image.read(image_path).first
    end

    def generate!
      merge
      save
      @temp_image_target
    end

    def width
      @width ||= @base_image.columns
    end

    def height
      @height ||= [@base_image.rows, @image.rows].max
    end

    def x_off_ratio
      @x_off_ratio ||= X_OFF_RATIO
    end

    def y_off_ratio
      @y_off_ratio ||= Y_OFF_RATIO
    end

    def x_off
      @x_off ||= resized_base_image.columns * x_off_ratio
    end

    def y_off
      @y_off ||= height * y_off_ratio
    end

    def image_width
      @image_width ||= width - x_off
    end

    def image_height
      @image_height ||= height - (y_off * 2)
    end

    def resized_base_image
      @resized_base_image ||= adjust_base_image
    end

    def resized_image
      @resized_image ||= adjust_image
    end

    def gravity
      @gravity ||= nil
    end

    private

      def adjust_base_image
        resized_to_fit = @base_image.resize_to_fit(nil, height)
        return resized_to_fit unless resized_to_fit.columns > width

        @base_image.resize(width, height)
      end

      def adjust_image
        @image.resize(image_width, image_height)
      end

      def merge
        @result = Magick::Image.new(width, height) do |img|
          img.background_color = 'transparent'
        end
        @result.composite!(resized_base_image, 0, 0, Magick::OverCompositeOp)

        insert_image
      end

      def insert_image
        if gravity.present?
          @result.composite!(resized_image, gravity, x_off, y_off, Magick::OverCompositeOp)
        else
          @result.composite!(resized_image, x_off, y_off, Magick::OverCompositeOp)
        end
      end

      def save
        @result.write(@temp_image_target.path)
      end
  end
end
