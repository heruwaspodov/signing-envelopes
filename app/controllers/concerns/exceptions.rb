# frozen_string_literal: true

module Exceptions
  class NotAllowedToDoThisAction < StandardError
    def message
      I18n.t 'error.validation.not_allowed_to_do_this_action'
    end
  end

  class MissingParameter < StandardError
    def initialize(param)
      @param = param
      super
    end

    def message
      I18n.t 'error.validation.parameter_required', param: @param
    end
  end

  class UnprocessableRequest < StandardError
    attr_reader :message

    def initialize(message)
      super
      @message = message
    end
  end

  class PeruriRequest < StandardError
    attr_reader :response, :envelope

    def initialize(response, envelope)
      code = response['statusCode'] || response['errorCode']

      super "Error stamping #{envelope.id}: #{code} - #{response}"
    end
  end

  class RedisKeyAlreadyExists < StandardError; end
  class UnauthorizedAccess < StandardError; end
end
