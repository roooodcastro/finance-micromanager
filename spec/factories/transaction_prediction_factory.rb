# frozen_string_literal: true

FactoryBot.define do
  factory :transaction_prediction do
    profile { association(:profile) }

    sequence(:name, 'Prediction AAA')
    rules_json { '{}' }

    trait :disabled do
      disabled_at { Time.current }
      after(:create) { |prediction| prediction.update!(disabled_by: prediction.profile.user) }
    end
  end
end
