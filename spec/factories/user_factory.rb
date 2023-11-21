# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:first_name) { |n| "First #{n}" }
    sequence(:last_name) { |n| "First #{n}" }
    sequence(:email) { |n| "email_#{n}@email.com" }
    sequence(:password) { |n| "testing#{n}" }

    default_wallet { build(:wallet, user: nil) } # rubocop:disable FactoryBot/FactoryAssociationWithStrategy

    after(:build) do |user|
      user.default_wallet.user = user if user.default_wallet
    end

    after(:create, &:confirm)
  end
end
