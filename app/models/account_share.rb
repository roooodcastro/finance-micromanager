# frozen_string_literal: true

class AccountShare < ApplicationRecord
  self.implicit_order_column = :created_at

  belongs_to :account
  belongs_to :user

  validate :validate_no_owner_self_sharing

  private

  # Account owner can't share the account with themselves
  def validate_no_owner_self_sharing
    return if user != account.user

    errors.add(:user, :owner_self_share)
  end
end
