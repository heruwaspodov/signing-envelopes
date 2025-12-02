# frozen_string_literal: true

module Annotations
  class AnnotationDummyMeterai < Annotations::AnnotationSignature
    def process!
      setup_image_rotation
      sign
      @document
    end

    def name
      "dummy_meterai_#{SecureRandom.hex(5)}"
    end

    def reason
      'Dummy Meterai'
    end
  end
end
