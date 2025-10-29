# frozen_string_literal: true

FactoryBot.define do
  factory :transaction_automation do
    profile { association(:profile) }

    sequence(:transaction_name, 'Transaction AAA')
    transaction_amount { 10.00 }
    transaction_category { association(:category, profile:) }

    schedule_type { TransactionAutomation.schedule_types[:month] }
    schedule_interval { 1 }
    scheduled_date { Date.current }
    schedule_day { Date.current.day }
    weekend_rule { :allow }

    trait :schedule_type_week do
      schedule_type { TransactionAutomation.schedule_types[:week] }
      schedule_interval { 1 }
      scheduled_date { Date.current }
      schedule_day { 1 } # Monday
      weekend_rule { nil }
    end

    trait :schedule_type_last_weekday_of_month do
      schedule_type { TransactionAutomation.schedule_types[:custom] }
      schedule_custom_rule { TransactionAutomations::CustomRule::LAST_BUSINESS_DAY_OF_MONTH }
      schedule_interval { nil }
      schedule_day { nil }
      weekend_rule { nil }
    end

    trait :disabled do
      disabled_at { Time.current }
      after(:create) { |automation| automation.update!(disabled_by: automation.profile.user) }
    end
  end
end
