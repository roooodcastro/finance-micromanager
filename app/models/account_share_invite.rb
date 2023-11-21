# frozen_string_literal: true

class AccountShareInvite < ApplicationRecord
  self.implicit_order_column = :created_at

  belongs_to :account
  belongs_to :account_owner, class_name: 'User'

  has_one :invitee, class_name: 'User', foreign_key: :email, primary_key: :invitee_email,
          dependent: :restrict_with_exception, inverse_of: :account_share_invites_received

  validates :invitee_email, presence: true, uniqueness: { scope: :account_id }

  enum status: { pending: 'pending', accepted: 'accepted', rejected: 'rejected', cancelled: 'cancelled' }

  def as_json(*)
    super(except: %w[created_at updated_at]).merge(account: account.as_json, account_owner: account_owner.as_json)
  end

  def accept!
    transaction do
      accepted!
      AccountShare.create!(account: account, user: invitee)
    end
  end
end
