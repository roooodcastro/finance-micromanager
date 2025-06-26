# frozen_string_literal: true

FactoryBot.define do
  factory :budget_instance do
    profile
    budget
    owner { create(:category) }

    limit_type { 'absolute' }
    limit_amount { 100 }
    limit_percentage { nil }
    start_date { Date.current.beginning_of_month }
    end_date { Date.current.end_of_month.end_of_day }

    trait :from_budget do
      after(:build) do |budget_instance|
        budget_instance.profile          = budget_instance.budget.profile
        budget_instance.owner            = budget_instance.budget.owner
        budget_instance.limit_type       = budget_instance.budget.limit_type
        budget_instance.limit_amount     = budget_instance.budget.limit_amount
        budget_instance.limit_percentage = budget_instance.budget.limit_percentage
      end
    end

    trait :category do
      owner { Category.last }
    end

    trait :profile do
      owner { Profile.last }
    end

    trait :absolute do
      limit_type { :absolute }
      limit_amount { 100 }
      limit_percentage { nil }
    end

    trait :percentage do
      limit_type { :percentage }
      limit_amount_cents { nil }
      limit_percentage { 10 }
    end

    trait :remainder do
      limit_type { :remainder }
      limit_amount { nil }
      limit_percentage { nil }
    end

    trait :disabled do
      disabled_at { Time.current }
    end
  end
end
