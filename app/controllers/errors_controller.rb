# frozen_string_literal: true

require 'English'
class ErrorsController < ApplicationController
  def internal_server_error
    respond_to do |format|
      format.any do
        error_response = { error: 'Something went wrong, please contact our support' }
        error_response[:backtrace] = $ERROR_INFO.backtrace unless Rails.env.production?
        render json: error_response, status: :internal_server_error
      end
    end
  end
end
