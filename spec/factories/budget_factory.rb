# frozen_string_literal: true

FactoryBot.define do
  factory :budget do
    profile

    limit_type { :absolute }
    limit_amount { 100 }
    limit_percentage { nil }

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
      limit_amount { nil }
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
