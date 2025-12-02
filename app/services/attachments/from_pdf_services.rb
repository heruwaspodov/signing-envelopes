# frozen_string_literal: true

module Attachments
  require 'libreconv'

  class FromPdfServices < AttachmentFileServices
    def exec!
      @tempfile_target = @file.tempfile
    end
  end
end
