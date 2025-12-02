# frozen_string_literal: true

module EsignStorage
  class Amazon < EsignStorage::Interface
    def upload(file, filename, path)
      Amazons::S3ObjectUpload.new(file, filename, path).upload_image
    end

    # return file
    def get(object_key, tempfile)
      tempfile = tempfile.path if tempfile.is_a?(File) || tempfile.is_a?(Tempfile)

      Amazons::S3ObjectGet.new(object_key, tempfile).get
    end

    def copy(object_key, target_key)
      Amazons::S3ObjectCopy.new(object_key, target_key).copy_file
    end

    def exists?(object_key)
      Amazons::S3CheckObject.new(object_key).exists?
    end

    def list_objects
      raise 'Unsupported method'
    end

    def delete
      raise 'Unsupported method'
    end
  end
end
