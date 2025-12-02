# frozen_string_literal: true

module Attachments
  require 'libreconv'

  class FromImgServices < AttachmentFileServices
    def exec!
      img = Magick::ImageList.new(@file.tempfile.path)
      img.write(@tempfile_target.path)
      @tempfile_target
    end
  end
end
