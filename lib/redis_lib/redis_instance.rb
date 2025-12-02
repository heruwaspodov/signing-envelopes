# frozen_string_literal: true

module RedisLib
  class RedisInstance
    attr_accessor :make_connection

    def initialize
      url = ENV['CACHE_REDIS_URL'] || ENV.fetch('REDIS_URL', nil)
      @make_connection = Redis.new(url: url)
    end

    def set_redis(key, value = nil)
      @make_connection.set(key, value)
    end

    def get_redis(key)
      @make_connection.get(key)
    end

    def keys_redis(key)
      @make_connection.keys(key)
    end

    def incr_redis(key)
      @make_connection.incr(key)
    end

    def expire_redis(key, time)
      @make_connection.expire(key, time)
    end

    def ttl_redis(key)
      @make_connection.ttl(key)
    end

    def rename_redis(old_key, new_key)
      @make_connection.rename(old_key, new_key)
    end

    def exists_redis(key)
      @make_connection.exists(key)
    end

    def del_redis(key)
      @make_connection.del(key)
    end

    def setnx(key, value, expiry = nil)
      raise Exceptions::RedisKeyAlreadyExists unless @make_connection.setnx(key, value)

      @make_connection.expire(key, expiry) if expiry.present?
    end
  end
end
