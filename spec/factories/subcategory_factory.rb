# frozen_string_literal: true

FactoryBot.define do
  factory :subcategory do
    sequence(:name) { |n| "Subcategory #{n}" }
    category
  end
end
