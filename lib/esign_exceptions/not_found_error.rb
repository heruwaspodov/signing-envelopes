# frozen_string_literal: true

module EsignExceptions
  class NotFoundError < Errors
    attr_reader :code, :message

    def initialize(message = I18n.t('error.validation.not_found'))
      @code = 'MSN-404'
      @message = message

      super(@message)
    end
  end
end
