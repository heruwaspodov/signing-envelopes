# frozen_string_literal: true

module Alerts
  module GoogleChat
    module Channels
      class ErrorAlert < Alerts::GoogleChat::Channels::General
        def channel_by_config_db
          config_env || config_db
        end

        def config_db
          Config.find_by(key: Config::KEY_GOOGLE_CHAT_CHANNEL_ERROR_ALERT)&.value
        end

        def config_env
          ENV['GOOGLE_CHAT_CHANNEL_ERROR_ALERT']
        end
      end
    end
  end
end
