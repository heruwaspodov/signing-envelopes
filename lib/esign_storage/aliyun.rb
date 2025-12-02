# frozen_string_literal: true

module EsignStorage
  class Aliyun < EsignStorage::Interface
    # rubocop:disable Style/OpenStructUse
    def upload(file, filename, path = nil)
      filename = "#{path}/#{filename}" if path.present?

      if file.is_a?(String)
        # FIXME: this function is tailored for uploading object with PNG as extension
        tempfile = Tempfile.new([filename, '.png'])
        tempfile.binmode
        tempfile.write(file)
        tempfile.rewind

        file = tempfile
      end

      key = (filename if AliyunOss.upload(filename, file))

      OpenStruct.new(key: key)
    ensure
      tempfile&.close
    end
    # rubocop:enable Style/OpenStructUse

    # return file
    def get(object_key, tempfile)
      AliyunOss.get(object_key, tempfile)
    end

    def copy(object_key, target_key)
      AliyunOss.copy(object_key, target_key)
    end

    def exist?(object_key)
      AliyunOss.exist?(object_key)
    end

    def list_objects
      AliyunOss.list_objects
    end

    def delete(object_key)
      AliyunOss.delete(object_key)
    end
  end
end
