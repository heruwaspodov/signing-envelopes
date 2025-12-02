# frozen_string_literal: true

module ToFile
  def to_file(ext = nil)
    data = Base64.strict_decode64(split(',')&.last)

    temp_file = Tempfile.new(%W[to_file_#{SecureRandom.hex(7)} .#{ext.nil? ? 'png' : ext}])
    temp_file.binmode
    temp_file.write(data)
    temp_file.rewind

    temp_file
  end
end

class String; include ToFile; end
