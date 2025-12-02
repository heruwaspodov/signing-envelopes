# frozen_string_literal: true

module MailerHelper
  def app_base_url
    ENV['APP_URL'] || 'https://app-sign.mekari.io'
  end

  def mailer_sender(name = 'Mekari Sign')
    sender = ENV['SMTP_SENDER'] || 'no-reply.esign@mekari.com'
    "#{name} <#{sender}>"
  end

  def docmaker_mailbox(envelope)
    return nil if envelope.nil? || envelope.user.nil?

    docmaker = envelope.user
    "#{docmaker.full_name} <#{docmaker.email}>"
  end

  def banner_image_config
    @banner_image_config ||= Rails.cache
                                  .fetch(
                                    "config:#{Config::KEY_BANNER_IMAGE_EMAIL_FOOTER}",
                                    skip_nil: true,
                                    expires_in: 1.day
                                  ) do
      Config.find_by_key(Config::KEY_BANNER_IMAGE_EMAIL_FOOTER)&.value
    end
  end

  def banner_image
    @banner_image ||= if banner_image_config.nil?
                        "#{ENV['HOST_PROD'] || 'https://api.esign.mekari.com/core'}/mekari-sign-banner-2.png"
                      else
                        banner_image_config
                      end
  end

  def cobrand_setting(user)
    email_setting = user&.email_settings&.last
    company_logo = email_setting&.company_logo_url
    sender = email_setting&.sender_name
    @company_logo_url = company_logo if company_logo.present?
    @sender = define_sender_name(sender)
  end

  def define_sender_name(sender)
    if sender.present? && sender != 'Mekari Sign'
      mailer_sender("#{sender} via Mekari Sign")
    else
      mailer_sender
    end
  end

  def create_wa_url(message_type)
    msg = Configs::ConfigServices.new.send("wa_message_top_up_#{message_type}")
    "https://api.whatsapp.com/send/?phone=#{Configs::ConfigServices.new.wa_number}&text=#{CGI.escape(msg)}"
  end
end
