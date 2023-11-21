# frozen_string_literal: true

FactoryBot.define do
  factory :account_share_invite do
    sequence(:invitee_email) { |n| "invitee_email_#{n}@email.com" }
    status { :pending }
    account_owner { association(:user) }
    account { association(:account, user: account_owner) }

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
