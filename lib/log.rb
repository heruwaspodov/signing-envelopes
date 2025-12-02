# frozen_string_literal: true

module Log
  class << self
    def info(subject, content)
      @subject = subject
      @content = content

      Rails.logger.info content_forward
    end

    def error(subject, content)
      @subject = subject
      @content = content

      Rails.logger.error content_forward
    end

    private

      def content_forward
        {
          subject: @subject,
          content: @content
        }.to_json
      end
  end
end
