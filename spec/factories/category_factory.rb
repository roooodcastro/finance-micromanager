# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    color { '#808080' }
    account { create(:account) }
  end
end
