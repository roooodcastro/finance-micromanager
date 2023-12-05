# frozen_string_literal: true

FactoryBot.define do
  factory :profile_share do
    profile
    user
  end
end
