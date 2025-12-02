# frozen_string_literal: true

module ToBase64
  def to_base64
    file = begin
      is_a?(File) || is_a?(Tempfile) ? self : tempfile
    rescue NoMethodError
      self
    end

    mime_type = FileMagic.new(FileMagic::MAGIC_MIME).file(file.path, true)

    "data:#{mime_type};base64," + Base64.strict_encode64(File.read(file))
  end
end

module ActionDispatch
  module Http
    class UploadedFile; include ToBase64; end
  end
end

module Rack
  module Test
    class UploadedFile; include ToBase64; end
  end
end

class File; include ToBase64; end
class Tempfile; include ToBase64; end
