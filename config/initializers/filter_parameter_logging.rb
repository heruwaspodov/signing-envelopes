# frozen_string_literal: true

module ParameterFiltering
  AUTHENTICATION_PARAMS = %i[passw secret token _key crypt salt otp current_password new_password].freeze
  PERSONAL_INFO_PARAMS = %i[ssn nik phone email].freeze
  DOCUMENT_PARAMS = %i[certificate doc passport_file company_supporting_document pdf docs].freeze
  IMAGE_PARAMS = %i[photo_selfie photo_ktp images initial_images avatar logo].freeze
  SIGNATURE_PARAMS = %i[initial signature value].freeze

  def self.all_filtered_parameters
    base_params = AUTHENTICATION_PARAMS +
                  PERSONAL_INFO_PARAMS +
                  DOCUMENT_PARAMS +
                  IMAGE_PARAMS

    base_params += SIGNATURE_PARAMS if show_signature_params?

    base_params
  end

  def self.show_signature_params?
    return true if ENV['LOG_SIGNATURE_PARAMS'] == true || ENV['LOG_SIGNATURE_PARAMS'] == 'true'

    false
  end
end

# Configure sensitive parameters which will be filtered from the log file
Rails.application.config.filter_parameters += ParameterFiltering.all_filtered_parameters
