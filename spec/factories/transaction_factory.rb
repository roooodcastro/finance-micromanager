# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    sequence(:name) { |n| "Transaction #{n}" }
    amount { 10.00 }
    transaction_date { Time.current }

    created_by { association(:user) }
    updated_by { association(:user) }
    profile { association(:profile, user: created_by) }
    category { association(:category, profile:) }
  end
end
