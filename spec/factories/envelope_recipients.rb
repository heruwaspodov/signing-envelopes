# frozen_string_literal: true

FactoryBot.define do
  factory :envelope_recipient do
    email { Faker::Internet.email }
  end
end
