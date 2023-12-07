# frozen_string_literal: true

class ProfileShare < ApplicationRecord
  belongs_to :profile
  belongs_to :user

  validate :validate_no_owner_self_sharing

  private

  # Profile owner can't share the profile with themselves
  def validate_no_owner_self_sharing
    return if user != profile.user

    errors.add(:user, :owner_self_share)
  end
end
