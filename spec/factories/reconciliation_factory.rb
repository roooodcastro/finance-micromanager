# frozen_string_literal: true

FactoryBot.define do
  factory :reconciliation do
    date { 1.day.ago }
    profile

    trait :in_progress do
      status { :in_progress }
    end

    trait :finished do
      status { :finished }
    end

    trait :cancelled do
      status { :cancelled }
    end
  end
end
