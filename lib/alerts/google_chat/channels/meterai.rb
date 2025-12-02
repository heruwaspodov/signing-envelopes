# frozen_string_literal: true

module Alerts
  module GoogleChat
    module Channels
      class Meterai < Alerts::GoogleChat::Channels::General
        def channel_by_config_db
          Rails.cache.fetch('google_chat_channel_meterai', expires_in: 1.day, ignore_nil: true) do
            Config.find_by(key: Config::KEY_GOOGLE_CHAT_CHANNEL_METERAI)&.value
          end
        end
      end
    end
  end
end
