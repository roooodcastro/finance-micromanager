# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    sequence(:name) { |n| "Transaction #{n}" }
    amount { 10.00 }
    transaction_date { Time.current }

    account
    category { association(:category, account:) }
  end
end
