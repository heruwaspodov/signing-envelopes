# frozen_string_literal: true

# https://github.com/Netflix/fast_jsonapi/issues/184
class ApplicationSerializer
  include JSONAPI::Serializer
  # cache_options store: Rails.cache,
  #               namespace: 'jsonapi-serializer',
  #               expires_in: 1.hour

  def to_h
    data = serializable_hash
    data_condition(data)
  end

  def data_condition(data)
    case data[:data]
    when Hash
      data[:data][:attributes]
    when Array
      data[:data].map { |x| x[:attributes] }
    when nil
      nil
    else
      data
    end
  end

  class << self
    def one(resource, options = {})
      source = "#{resource.to_s.classify}Serializer".constantize
      serializer = options[:serializer] || source

      attribute resource do |object|
        serializer.new(object.try(resource)).to_h
      end
    end

    def many(resources, options = {})
      source = "#{resources.to_s.classify}Serializer".constantize
      serializer = options[:serializer] || source

      attribute resources do |object|
        serializer.new(object.try(resources)).to_h
      end
    end
  end
end
