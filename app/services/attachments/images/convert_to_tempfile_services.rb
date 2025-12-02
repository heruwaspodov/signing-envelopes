# frozen_string_literal: true

module Attachments
  module Images
    class ConvertToTempfileServices < Attachments::Images::ConvertFileTypeServices
      def call
        convert
      end
    end
  end
end
