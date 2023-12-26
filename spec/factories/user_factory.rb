# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:first_name, 'First AAA')
    sequence(:last_name, 'Last AAA')
    sequence(:email, 'email@email.aaa')
    sequence(:password, 'aaaaaa')

    default_profile { build(:profile, user: nil) } # rubocop:disable FactoryBot/FactoryAssociationWithStrategy

    after(:build) do |user|
      user.default_profile.user = user if user.default_profile
    end

    after(:create, &:confirm)
  end
end
