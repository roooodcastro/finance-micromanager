# frozen_string_literal: true

class WalletShare < ApplicationRecord
  self.implicit_order_column = :created_at

  belongs_to :wallet
  belongs_to :user

  validate :validate_no_owner_self_sharing

  private

  # Wallet owner can't share the wallet with themselves
  def validate_no_owner_self_sharing
    return if user != wallet.user

    errors.add(:user, :owner_self_share)
  end
end
