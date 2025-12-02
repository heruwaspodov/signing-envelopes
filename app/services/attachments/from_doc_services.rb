# frozen_string_literal: true

module Attachments
  require 'libreconv'

  class FromDocServices < AttachmentFileServices
    def exec!
      Libreconv.convert(@file.tempfile.path, @tempfile_target.path)
      @tempfile_target
    end
  end
end
