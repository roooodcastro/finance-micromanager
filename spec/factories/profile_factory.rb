# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    status { :active }
    currency { :usd }
    user

    trait :active do
      status { :active }
    end

    trait :disabled do
      status { :disabled }
    end
  end
end