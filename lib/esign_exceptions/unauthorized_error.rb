# frozen_string_literal: true

module EsignExceptions
  class UnauthorizedError < Errors
    attr_reader :code, :message

    def initialize(message = I18n.t('error.validation.unauthorized'), code = 'MSN-401')
      @code = code
      @message = message

      super(@message)
    end
  end
end
