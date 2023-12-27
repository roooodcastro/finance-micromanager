# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    sequence(:name, 'Category AAA')
    color { '#808080' }
    profile

    trait :system do
      category_type { :system }
    end
  end
end
