# frozen_string_literal: true

FactoryBot.define do
  factory :transaction_automation do
    profile { association(:profile) }

    sequence(:transaction_name, 'Transaction AAA')
    transaction_amount { 10.00 }
    transaction_category { association(:category, profile:) }

    schedule_type { schedule_types[:month] }
    schedule_interval { 1 }
    next_schedule_date { Date.current }

    trait :disabled do
      disabled_at { Time.current }
      disabled_by { profile.user }
    end
  end
end
