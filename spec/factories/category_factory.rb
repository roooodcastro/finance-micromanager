# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    sequence(:name, 'Category AAA')
    color { '#808080' }
    profile
  end
end
