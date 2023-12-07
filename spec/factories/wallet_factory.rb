# frozen_string_literal: true

FactoryBot.define do
  factory :wallet do
    sequence(:name) { |n| "Wallet #{n}" }
    balance { 0 }
    profile

    trait :disabled do
      disabled_at { Time.current }
      disabled_by { association(:user) }
    end
  end
end
