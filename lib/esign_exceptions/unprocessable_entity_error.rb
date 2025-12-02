# frozen_string_literal: true

module EsignExceptions
  class UnprocessableEntityError < Errors
    attr_reader :code, :errors, :message

    def initialize(errors, message = I18n.t('error.validation.unprocessable_entity'))
      @code = 'MSN-422'
      @errors = errors
      @message = message

      super(@message)
    end
  end
end
