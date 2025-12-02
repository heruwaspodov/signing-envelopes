# frozen_string_literal: true

module Notifications
  class Notify
    attr_accessor :whatsapp, :email

    def initialize(params)
      allowed_params.each do |param|
        next unless params[param.to_sym].present?

        instance_variable_set("@#{param}", params[param.to_sym])
      end
    end

    def allowed_params
      %w[]
    end

    def via_whatsapp
      raise NotImplementedError,
            "#{self.class} has not implemented method '#{__method__}'"
    end

    def via_email
      raise NotImplementedError,
            "#{self.class} has not implemented method '#{__method__}'"
    end

    def whatsapp?
      @whatsapp.to_bool && whatsapp_enable?
    end

    def email?
      @email.to_bool
    end

    def send!
      via_whatsapp if whatsapp?
      via_email if email?
    end

    def whatsapp_enable?
      Rails.cache.fetch("config:#{Config::KEY_WA_ENABLE}", expires_in: 1.days) do
        Config.where(key: Config::KEY_WA_ENABLE).first_or_initialize.value.to_bool
      end
    end

    def notify_owner?(user)
      service = NotificationSettings::ShowServices.new(user)
      service.values.try(:document_completed_whatsapp_for_doc_maker).to_bool
    end
  end
end
