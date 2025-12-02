# frozen_string_literal: true

FactoryBot.define do
  factory :envelope do
    sequence :filename do |n|
      "Envelope #{n}"
    end
  end
end
