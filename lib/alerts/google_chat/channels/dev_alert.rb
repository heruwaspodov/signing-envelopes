# frozen_string_literal: true

module Alerts
  module GoogleChat
    module Channels
      class DevAlert < Alerts::GoogleChat::Channels::General
        def channel_by_config_db
          Config.find_by(key: Config::KEY_GOOGLE_CHAT_CHANNEL_DEV_ALERT)&.value
        end
      end
    end
  end
end
