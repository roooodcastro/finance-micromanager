# frozen_string_literal: true

FactoryBot.define do
  factory :account_share do
    account
    user
  end
end
