# frozen_string_literal: true

module Alerts
  module Flock
    module Channels
      class DevAlert < Alerts::Channel
        def channel
          unless channel_by_config.present?
            raise Alerts::Errors::ChannelConfigNotFound, I18n.t('error.validation.not_found')
          end

          channel_by_config
        end

        def channel_by_config
          ENV['FLOCK_DEV_ALERT_WEBHOOK']
        end
      end
    end
  end
end
