# frozen_string_literal: true

module TextAsJson
  def json(str)
    formatted = str.gsub('//', '')
    formatted = formatted.gsub('=>', ':')
    formatted.gsub('nil', 'null')
  end

  module_function :json
end
