# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    sequence(:name, 'Category AAA')
    color { '#808080' }
    profile

    trait :enabled do
      disabled_at { nil }
    end

    trait :disabled do
      disabled_at { Time.current }
    end

    trait :system do
      category_type { :system }
    end
  end
end
