# frozen_string_literal: true

module Alerts
  module GoogleChat
    module Channels
      class General < Alerts::Channel
        def channel
          channel_by_db = channel_by_config_db

          unless channel_by_db.present?
            raise Alerts::Errors::ChannelConfigNotFound, I18n.t('error.validation.not_found')
          end

          channel_by_db
        end

        def channel_by_config_db
          # raise NoMethodError
          raise NotImplementedError,
                "#{self.class} has not implemented method '#{__method__}'"
        end
      end
    end
  end
end
