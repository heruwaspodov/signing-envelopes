# frozen_string_literal: true

module Files
  class ImageValidation < FileValidation
    SUPPORTED_FILETYPE = %w[
      image/jpeg
      image/png
      image/heif
      image/heic
    ].freeze

    MIME_HEIC = %w[
      image/heic
      image/heif
      data:image/heic;base64
      data:image/heif;base64
    ].freeze

    def types
      SUPPORTED_FILETYPE
    end
  end
end
