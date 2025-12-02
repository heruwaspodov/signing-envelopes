# frozen_string_literal: true

module ToBoolean
  def to_bool
    return true if self == true || to_s.strip =~ /^(true|yes|y|1)$/i

    false
  end
end

class NilClass; include ToBoolean; end
class TrueClass; include ToBoolean; end
class FalseClass; include ToBoolean; end
class Numeric; include ToBoolean; end
class String; include ToBoolean; end
