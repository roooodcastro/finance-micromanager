# frozen_string_literal: true

FactoryBot.define do
  factory :sub_category do
    sequence(:name) { |n| "SubCategory #{n}" }
    category
  end
end
