# frozen_string_literal: true

module EsignExceptions
  class Errors < StandardError
    class CompanyNotFound < Errors; end
    class WorkspaceNotFound < Errors; end
  end
end
