# frozen_string_literal: true

FactoryBot.define do
  factory :subcategory do
    sequence(:name) { |n| "Subcategory #{n}" }
    category

    trait :disabled do
      disabled_at { Time.current }
      disabled_by { association(:user) }
    end
  end
end
