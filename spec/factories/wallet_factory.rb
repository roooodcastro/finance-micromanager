# frozen_string_literal: true

FactoryBot.define do
  factory :wallet do
    sequence(:name, 'Wallet AAA')
    balance { 0 }
    profile

    trait :enabled do
      disabled_at { nil }
    end

    trait :disabled do
      disabled_at { Time.current }
      disabled_by { association(:user) }
    end
  end
end
