# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:first_name) { |n| "First #{n}" }
    sequence(:last_name) { |n| "First #{n}" }
    sequence(:email) { |n| "email_#{n}@email.com" }
    sequence(:password) { |n| "testing#{n}" }

    after(:create, &:confirm)
  end
end
