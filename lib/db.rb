# frozen_string_literal: true

module Db
  def self.read(user: nil, &block)
    role = Flipper.enabled?(:ft_use_replica, user) ? :reading : :writing
    ActiveRecord::Base.connected_to(role: role, &block)
  end
end
