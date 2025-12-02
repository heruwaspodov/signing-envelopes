# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  attr_accessor :recipient, :envelope

  include MailerHelper

  default from: mailer_sender

  layout 'mailer'

  before_action do
    @company_logo_url = "#{ENV['HOST_PROD'] || 'https://api.esign.mekari.com/core'}/Mekari-Sign.png"
  end

  def params_default
    {
      user: auth? ? 'auth' : 'no_auth',
      envelope: encrypted
    }
  end

  def auth?
    return true if @recipient.is_a?(User)
    return true if @recipient.recipient_id.present?

    false
  end

  def params_default_owner
    {
      user: 'auth',
      envelope: encrypted_owner
    }
  end

  def params_for_sign_owner
    params_default_owner.to_query
  end

  def params_for_sign
    params_default.to_query
  end

  def params_invite_to_sign
    params_default.merge({
                           qr_code_signature: true
                         })
                  .to_query
  end

  def params_for_status
    params_default.merge(
      {
        trails: true
      }
    ).to_query
  end

  def encrypted
    encrypted_params = "#{@envelope.id}|#{@recipient.email}"
    EncryptionString.encrypt(encrypted_params)
  end

  def encrypted_owner
    encrypted_params = "#{@envelope.id}|#{@envelope.user.email}"
    EncryptionString.encrypt(encrypted_params)
  end

  def utm_params(campaign_type = nil)
    return '' unless campaign_type

    utm_campaigns = {
      ekyc: 'ekyc%20verification',
      document_signers: 'document%20signers',
      request_docs_access: 'request%20docs%20access',
      user_invitation: 'user%20invitation'
    }

    campaign = utm_campaigns[campaign_type.to_sym]
    return '' unless campaign

    "&utm_source=ecosystem&utm_medium=in-app&utm_campaign=#{campaign}"
  end

  def utm_campaign_for_mailer
    case self.class.name
    when 'KycRegistrationMailer'
      :ekyc
    when 'DocumentNotificationMailer', 'EnvelopeCommentMailer', 'AutoSignMailer'
      :document_signers
    when 'UserManagementMailer::AccessRequestMailer::DocumentMailer'
      :request_docs_access
    when 'UserManagementMailer::InvitationMailer::JoinMailer'
      :user_invitation
    end
  end

  def add_utm_to_url(url, campaign_type = nil)
    # Determine user context for feature flag
    user = determine_user_context

    # Check feature flag - return original URL if disabled
    return url unless Flipper.enabled?(:ft_email_utm_campaign, user)

    return url unless campaign_type || utm_campaign_for_mailer

    campaign = campaign_type || utm_campaign_for_mailer
    utm_string = utm_params(campaign)
    return url if utm_string.empty?

    separator = url.include?('?') ? '&' : '?'
    "#{url}#{separator}#{utm_string.sub('&', '')}"
  end

  def determine_user_context
    user_from_recipient ||
      user_from_envelope ||
      user_from_instance_variable ||
      user_from_email
  end

  def allow_to_send?(recipient, key, user = nil)
    empty = !recipient.try(:recipient_id).present? && user.nil?
    return true if empty

    user = recipient.user if user.nil?

    return true if user.nil?

    service = NotificationSettings::ShowServices.new(user)

    return true unless service.values.respond_to?(key)

    allow = service.values.send(key)

    return true if allow.nil?

    allow
  end

  NotificationParams = Struct.new(:type, :role, :key, keyword_init: true)
  # params = NotificationParams.new(type: 'envelopes', role: 'signer', key: 'recipient_signed')

  def allowed_to_send?(params, user)
    config = if user.nil? || user&.notification_setting&.config.nil?
               default_config
             else
               user.notification_setting.reload&.config
             end

    value = config.dig(params.type.to_s, params.role.to_s, params.key.to_s, 'value')
    value != false
  end

  def default_config
    config = Config.find_by(key: Config::KEY_DEFAULT_NOTIFICATION_SETTINGS).value
    JSON.parse(config.gsub('=>', ':').gsub('nil', 'null'))
  end

  private

    def user_from_recipient
      return @recipient.user if @recipient.respond_to?(:user) && @recipient.user
      return @recipient if @recipient.is_a?(User)

      nil
    end

    def user_from_envelope
      @envelope.user if @envelope.respond_to?(:user) && @envelope.user
    end

    def user_from_instance_variable
      @user if defined?(@user) && @user.is_a?(User)
    end

    def user_from_email
      email = @to || (@recipient.respond_to?(:email) ? @recipient.email : nil)
      User.find_by(email: email) if email.present?
    end

    def set_company_logo_url
      host = ENV['HOST_PROD'] || 'https://api.esign.mekari.com/core'
      @company_logo_url = "#{host}/Mekari-Sign.png"
    end
end
