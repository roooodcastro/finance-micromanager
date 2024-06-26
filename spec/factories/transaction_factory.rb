# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    sequence(:name, 'Transaction AAA')
    amount { 10.00 }
    transaction_date { Time.current }

    created_by { association(:user) }
    updated_by { created_by }
    profile { association(:profile, user: created_by) }
    category { association(:category, profile:) }
    wallet { association(:wallet, profile:) }

    trait :skip_validations do
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
