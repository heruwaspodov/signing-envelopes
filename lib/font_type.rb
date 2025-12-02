# frozen_string_literal: true

module FontType
  class << self
    def call(type)
      path = "app/assets/fonts/#{type}.ttf"

      File.exist?(path) ? path : Images::AnnotationText::FONT_TYPE
    end
  end
end
