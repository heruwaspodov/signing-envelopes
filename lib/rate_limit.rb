# frozen_string_literal: true

class RateLimit
  class Exceeded < EsignExceptions::TooManyRequestsError
    attr_reader :metadata

    def initialize(metadata)
      @metadata = metadata
    end

    def message
      I18n.t(
        'error.ratelimit.exceeded',
        limit: @metadata[:limit],
        usage: @metadata[:usage],
        remaining: @metadata[:remaining],
        reset: humanize(@metadata[:reset])
      )
    end

    private

      def humanize(secs)
        [[60, :seconds], [60, :minutes], [24, :hours],
         [Float::INFINITY, :days]].map do |count, name|
          next unless secs.positive?

          secs, n = secs.divmod(count)

          "#{n.to_i} #{name}" unless n.to_i.zero?
        end.compact.reverse.join(' ')
      end
  end

  SECOND = 0
  MINUTE = 1
  HOUR = 2
  DAY = 3
  MONTH = 4
  YEAR = 5

  REDIS_KEY_PREFIX = 'ratelimit'

  class << self
    # rubocop:disable Style/ClassVars
    def init(redis_key_prefix = REDIS_KEY_PREFIX)
      @@redis_key_prefix ||= redis_key_prefix
      @@connection ||= Redis.new(url: rate_limit_redis_url)
    end
    # rubocop:enable Style/ClassVars

    def throttle(key, limit, period = MINUTE)
      exec do
        key = "#{@@redis_key_prefix}:#{key}:#{suffix(period)}"
        increase(key, limit, period)
      end
    end

    private

      def exec
        init
        yield
      end

      def increase(key, limit, period)
        value = @@connection.incr(key)
        metadata = metadata(value, limit, period)

        exceeded(metadata) if value > limit

        @@connection.expire(key, metadata[:reset]) if value.eql? 1

        metadata
      end

      def exceeded(metadata)
        raise Exceeded, metadata
      end

      def metadata(value, limit, period)
        usage = value
        usage = limit if usage > limit
        remaining = limit - value
        remaining = 0 if remaining.negative?
        reset = expired_in(Time.zone.now.to_datetime, period)

        {
          value: value,
          usage: usage,
          limit: limit,
          remaining: remaining,
          reset: reset
        }
      end

      # rubocop:disable Style/ClassVars
      def rate_limit_redis_url
        @@rate_limit_redis_url ||= ENV.fetch('RATE_LIMIT_REDIS_URL') do
          ENV.fetch('REDIS_URL', nil)
        end
      end
      # rubocop:enable Style/ClassVars

      def suffix(period)
        format = case period
                 when SECOND
                   '%Y%m%d%H%M%S'
                 when MINUTE
                   '%Y%m%d%H%M'
                 when HOUR
                   '%Y%m%d%H'
                 when DAY
                   '%Y%m%d'
                 when MONTH
                   '%Y%m'
                 else
                   '%Y'
                 end
        DateTime.now.utc.strftime(format)
      end

      # rubocop:disable Metrics/AbcSize
      def expired_in(current_time, period = MINUTE)
        case period
        when SECOND
          1
        when MINUTE
          60 - current_time.second
        when HOUR
          minutes = 60 - current_time.minute
          second = current_time.second.zero? ? 0 : 60 - current_time.second
          (minutes * 60) + second
        when DAY
          next_day = (current_time + 1.day).beginning_of_day
          find_seconds(current_time, next_day)
        when MONTH
          next_month = (current_time + 1.month).beginning_of_month
          find_seconds(current_time, next_month)
        else
          next_year = (current_time + 1.year).beginning_of_year
          find_seconds(current_time, next_year)
        end
      end

      # rubocop:enable Metrics/AbcSize
      def find_seconds(start_time, end_time)
        ((end_time - start_time) * 24 * 60 * 60).to_i
      end
  end
end
