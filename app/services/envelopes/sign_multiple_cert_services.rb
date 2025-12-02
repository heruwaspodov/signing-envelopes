# frozen_string_literal: true

module Envelopes
  class SignMultipleCertServices < Envelopes::SignServices
    prepend Envelopes::SignMultipleCertBehavior
  end
end
