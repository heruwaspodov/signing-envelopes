# frozen_string_literal: true

module LoggerHelper
  def sanitize_params(params)
    max_length = 200

    # this method responsible to truncate the params attribute who has more than 200 characters
    # for example, the base_64 pdf file, or callback payload from third-party services
    return params if ENV['LOG_SIGNATURE_PARAMS'] == true || ENV['LOG_SIGNATURE_PARAMS'] == 'true'

    params.each do |key, value|
      params[key] = "#{value[0...max_length]} (TRUNCATED)" if value.is_a?(String) && value.length > max_length
    end

    params
  end
end
