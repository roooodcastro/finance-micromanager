# frozen_string_literal: true

FactoryBot.define do
  factory :reconciliation_wallet do
    balance_amount { 5 }
    reconciliation
    wallet
  end
end
