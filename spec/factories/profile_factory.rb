# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    status { :active }
    currency { :eur }
    user

    trait :disabled do
      disabled_at { Time.current }
    end
  end
end
