# frozen_string_literal: true

module Response
  def json_response(object, status, error, meta = nil)
    result = {
      data: object,
      status: status,
      error: error
    }

    result[:meta] = meta if meta.present?

    render json: result, status: status
  end

  def render_bad_request(resource_or_params,
                         message = I18n.t('error.validation.bad_request'))

    data = {
      message: message,
      params: resource_or_params
    }

    json_response(data, :bad_request, true)
  end

  def render_unprocessable_entity(resource_or_params,
                                  message = I18n.t(
                                    'error.validation.unprocessable_entity'
                                  ))

    data = {
      message: message,
      params: resource_or_params
    }

    json_response(data, :unprocessable_entity, true)
  end

  def render_error(resource_or_params,
                   error_code,
                   message = I18n.t('error.validation.error'))

    data = {
      message: message,
      params: resource_or_params
    }

    json_response(data, error_code, true)
  end

  def render_unauthorized(resource_or_params,
                          message = I18n.t('error.validation.unauthorized'),
                          confirm_url = nil)

    data = {
      message: message,
      params: resource_or_params,
      confirm_url: confirm_url
    }

    json_response(data, :unauthorized, true)
  end

  def render_not_found(resource_or_params)
    data = {
      message: I18n.t('error.validation.not_found'),
      params: resource_or_params
    }

    json_response(data, :not_found, true)
  end

  def render_forbidden(resource_or_params)
    data = {
      message: I18n.t('error.validation.forbidden'),
      params: resource_or_params
    }

    json_response(data, :forbidden, true)
  end

  def render_success(resource_or_params = {}, message = I18n.t('success.ok'))
    data = {
      message: message,
      params: resource_or_params
    }

    json_response(data, :ok, false)
  end

  def json_response_raw(status, error, meta = nil)
    result = {
      status: status,
      error: error
    }

    result[:meta] = meta if meta.present?

    render json: result, status: status
  end
end
