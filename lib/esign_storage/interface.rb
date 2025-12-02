# frozen_string_literal: true

module EsignStorage
  class Interface
    def upload
      raise NotImplementedError
    end

    def get
      raise NotImplementedError
    end

    def copy
      raise NotImplementedError
    end

    def exists?
      raise NotImplementedError
    end

    def list_objects
      raise NotImplementedError
    end

    def delete
      raise NotImplementedError
    end
  end
end
