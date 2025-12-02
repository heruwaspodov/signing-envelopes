# frozen_string_literal: true

module Images
  class MergeSeparateImage
    X_OFF_RATIO = 0.1
    Y_OFF_RATIO = 0.5

    attr_accessor :image
    attr_writer :x_off, :x_off_ratio, :y_off_ratio, :y_off, :width, :height, :gravity

    def initialize(image1_path, image2_path)
      @temp_image_target = Tempfile.new(%w[image_merge_separate .png])
      @image1 = Magick::Image.read(image1_path).first
      @image2 = Magick::Image.read(image2_path).first
    end

    def generate!
      if calculate_width < width * 0.1
        @image1.write(@temp_image_target.path)
      else
        canvas
        merge
        save
      end

      @temp_image_target
    end

    def width
      @width ||= @image1.columns + @image2.columns
    end

    def height
      @height ||= [@image1.rows, @image2.rows].max
    end

    def x_off_ratio
      @x_off_ratio ||= X_OFF_RATIO
    end

    def y_off_ratio
      @y_off_ratio ||= Y_OFF_RATIO
    end

    def x_off
      @x_off ||= 0
    end

    def y_off
      @y_off ||= 0
    end

    def gravity
      @gravity ||= nil
    end

    def canvas
      @canvas ||= Magick::Image.new(width, height) { |img| img.background_color = 'transparent' }
    end

    def calculate_image1
      @image1.resize_to_fit!(height)
      @image1
    end

    def calculate_image2
      if @image2.resize_to_fit(nil, calculate_height).columns < calculate_width
        @image2.resize_to_fit!(nil, calculate_height)
      else
        @image2.resize!(calculate_width, calculate_height)
      end
    end

    private

      def calculate_width
        width - calculate_image1.columns - (calculate_image1.columns * x_off_ratio * 2)
      end

      def calculate_height
        height * 0.4
      end

      def merge
        @canvas.composite!(calculate_image1, 0, 0, Magick::OverCompositeOp)
        calculate_image2
        merge_image2
      end

      def merge_image2
        @canvas.composite!(@image2,
                           width - calculate_width - (calculate_image1.columns * x_off_ratio),
                           (@height - @image2.rows) / 2,
                           Magick::OverCompositeOp)
      end

      def save
        @canvas.write(@temp_image_target.path)
      end
  end
end
