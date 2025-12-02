# frozen_string_literal: true

module TimeHelper
  def humanize(secs)
    [[60, :seconds], [60, :minutes], [24, :hours],
     [Float::INFINITY, :days]].map do |count, name|
      next unless secs.positive?

      secs, n = secs.divmod(count)

      "#{n.to_i} #{name}" unless n.to_i.zero?
    end.compact.reverse.join(' ')
  end

  module_function :humanize
end
