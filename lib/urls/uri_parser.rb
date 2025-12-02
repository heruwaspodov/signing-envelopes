# frozen_string_literal: true

require 'uri'

module Urls
  class UriParser
    attr_accessor :url, :uri_parse

    def initialize(url)
      @url = url
      @uri_parse = URI.parse(@url)
    end

    def valid_url?
      @uri_parse.is_a?(URI::HTTP) && !uri_parse.host.nil?
    rescue URI::InvalidURIError
      false
    end
  end
end
