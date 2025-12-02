# frozen_string_literal: true

module Alerts
  module GoogleChat
    module Channels
      class ManualVerification < Alerts::GoogleChat::Channels::General
        def channel_by_config_db
          Config.find_by(key: Config::KEY_GOOGLE_CHAT_CHANNEL_MANUAL_VERIFICATION)&.value
        end
      end
    end
  end
end
