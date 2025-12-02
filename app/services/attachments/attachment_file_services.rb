# frozen_string_literal: true

module Attachments
  class AttachmentFileServices
    attr_reader :file, :tempfile_target, :envelope

    def initialize(file, tempfile_target)
      @file = file
      @tempfile_target = tempfile_target
    end

    def exec!
      raise NotImplementedError,
            "#{self.class} has not implemented method '#{__method__}'"
    end
  end
end
