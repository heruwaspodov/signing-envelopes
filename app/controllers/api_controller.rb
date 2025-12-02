# frozen_string_literal: true

class ApiController < ActionController::API
  include ActionController::RequestForgeryProtection
  include Response
  include ExceptionHandler

  before_action :set_locale

  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  respond_to :json

  def append_info_to_payload(payload)
    super
    payload[:host] = request.host
    payload[:remote_ip] = request.remote_ip
  end

  rescue_from ActionController::RoutingError, with: -> { no_routes }

  # set locale
  def set_locale
    locale = extract_locale
    I18n.locale = locale_valid?(locale) ? locale : I18n.default_locale
  end

  def no_routes
    json_response({
                    routing_error: I18n.t('error.no_routes',
                                          method: request.method,
                                          path: request.path)
                  }, :not_found, true)
  end

  # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/PerceivedComplexity
  def meta_pagination(collection)
    current = collection.current_page
    per_page    = collection.limit_value
    total_pages = if collection.respond_to?(:total_pages)
                    begin
                      collection.total_pages
                    rescue StandardError
                      (collection.size + 1) > per_page ? current + 1 : current
                    end
                  else
                    (collection.size + 1) > per_page ? current + 1 : current
                  end
    total_data  = if collection.respond_to?(:total_count)
                    begin
                      collection.total_count
                    rescue StandardError
                      (current * per_page) + 1
                    end
                  else
                    (current * per_page) + 1
                  end

    return_pagination(current, total_pages, per_page, total_data)
  end
  # rubocop:enable Metrics/MethodLength,Metrics/AbcSize,Metrics/PerceivedComplexity

  private

    def return_pagination(current, total_pages, per_page, total_count)
      {
        pagination: {
          current_page: current,
          previous: (current > 1 ? (current - 1) : nil),
          next: (current == total_pages ? nil : (current + 1)),
          per_page: per_page,
          total_pages: total_pages,
          count: total_count
        }
      }
    end

    def locale_valid?(locale)
      I18n.available_locales.map(&:to_s).include?(locale)
    end

    def extract_locale
      accept_language = params[:locale] || request.env['HTTP_ACCEPT_LANGUAGE']
      return unless accept_language

      accept_language.scan(/^[a-z]{2}/).first
    end
end
