# frozen_string_literal: true

class WalletShareInvite < ApplicationRecord
  self.implicit_order_column = :created_at

  belongs_to :wallet
  belongs_to :wallet_owner, class_name: 'User'

  has_one :invitee, class_name: 'User', foreign_key: :email, primary_key: :invitee_email,
          dependent: nil, inverse_of: :wallet_share_invites_received

  validates :invitee_email, presence: true, uniqueness: { scope: :wallet_id }

  enum status: { pending: 'pending', accepted: 'accepted', rejected: 'rejected', cancelled: 'cancelled' }

  def self.new_invite(wallet_owner:, wallet_id:, invitee_email:)
    invite = find_or_initialize_by(
      wallet_owner:  wallet_owner,
      wallet_id:     wallet_id,
      invitee_email: invitee_email,
      status:        :cancelled
    )

    invite.status = :pending
    invite
  end

  def as_json(*)
    super(except: %w[created_at updated_at]).merge(wallet: wallet.as_json, wallet_owner: wallet_owner.as_json)
  end

  def accept!
    transaction do
      accepted!
      WalletShare.create!(wallet: wallet, user: invitee)
    end
  end
end
