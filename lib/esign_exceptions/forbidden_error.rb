# frozen_string_literal: true

module EsignExceptions
  class ForbiddenError < Errors
    attr_reader :code, :message

    def initialize(message = I18n.t('error.validation.forbidden'))
      @code = 'MSN-403'
      @message = message

      super(@message)
    end
  end
end
