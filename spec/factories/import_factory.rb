# frozen_string_literal: true

FactoryBot.define do
  factory :import do
    source { 'ptsb' }

    profile
    wallet

    trait :ptsb do
      source { 'ptsb' }
    end

    trait :n26 do
      source { 'n26' }
    end
  end
end
