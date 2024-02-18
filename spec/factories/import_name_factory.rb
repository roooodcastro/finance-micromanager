# frozen_string_literal: true

FactoryBot.define do
  factory :import_name do
    sequence(:import_name, 'Import AAA')
    sequence(:transaction_name, 'Transaction AAA')
    profile
  end
end
