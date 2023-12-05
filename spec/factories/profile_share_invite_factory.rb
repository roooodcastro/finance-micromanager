# frozen_string_literal: true

FactoryBot.define do
  factory :profile_share_invite do
    sequence(:invitee_email) { |n| "invitee_email_#{n}@email.com" }
    status { :pending }
    profile_owner { association(:user) }
    profile { association(:profile, user: profile_owner) }

    trait :pending do
      status { :pending }
    end

    trait :accepted do
      status { :accepted }
    end

    trait :rejected do
      status { :rejected }
    end

    trait :cancelled do
      status { :cancelled }
    end
  end
end
