# frozen_string_literal: true

module Attachments
  module Images
    class ConvertToBase64Services < Attachments::Images::ConvertFileTypeServices
      def call
        tempfile = convert
        mime_type = @target_type.eql?('png') ? 'image/png' : 'image/jpeg'
        base64_file = "data:#{mime_type};base64,#{Base64.strict_encode64(File.read(tempfile))}"
        tempfile.close!
        base64_file
      end
    end
  end
end
