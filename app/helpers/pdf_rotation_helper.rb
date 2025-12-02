# frozen_string_literal: true

module PdfRotationHelper
  extend ActiveSupport::Concern

  private

    def get_page_rotation(page)
      rotation = page[:Rotate] || 0
      rotation.respond_to?(:to_i) ? rotation.to_i : 0
    rescue StandardError => e
      Rails.logger.warn("Failed to get page rotation: #{e.class} - #{e.message}")
      0
    end

    def get_rotation_float(page)
      rotation = page[:Rotate] || 0
      rotation.respond_to?(:to_f) ? rotation.to_f : 0.0
    rescue StandardError => e
      Rails.logger.warn("Failed to get page rotation as float: #{e.class} - #{e.message}")
      0.0
    end
end
