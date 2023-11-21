# frozen_string_literal: true

FactoryBot.define do
  factory :wallet_share do
    wallet
    user
  end
end
