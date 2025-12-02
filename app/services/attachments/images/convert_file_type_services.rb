# frozen_string_literal: true

module Attachments
  module Images
    class ConvertFileTypeServices < ApplicationService
      CONVERT_TYPE_OPTIONS = %w[jpeg jpg png].freeze

      attr_reader :tempfile, :target_type

      def initialize(tempfile, target_type)
        @tempfile = tempfile
        @target_type = target_type.downcase
      end

      private

        def convert
          unless CONVERT_TYPE_OPTIONS.include?(@target_type)
            raise(StandardError, I18n.t('error.attachments.convert_allowed'))
          end

          file_path = @tempfile.path
          target_filename = "#{File.dirname(file_path)}/#{File.basename(file_path)}"
          converted_tempfile = Tempfile.new([target_filename, ".#{@target_type}"])

          # Can Only Convert to Image (PNG,JPG,JPEG) at the Moment
          convert_to_image(file_path, converted_tempfile)
          converted_tempfile
        end

        def convert_to_image(file_path, converted_tempfile)
          unless File.exist?(file_path) && File.readable?(file_path)
            raise StandardError, 'File does not exist or is not readable'
          end

          begin
            img = Magick::ImageList.new(file_path).first
            raise StandardError, 'Failed to read image or unsupported format' unless img

            white_bg = Magick::Image.new(img.columns, img.rows)
            white_bg.background_color = 'white'

            converted_img = white_bg.composite(img, Magick::CenterGravity, Magick::OverCompositeOp)
            converted_img.write(converted_tempfile.path)
          rescue Magick::ImageMagickError => e
            raise StandardError, "Image processing failed: #{e.message}"
          end
        end
    end
  end
end
