# frozen_string_literal: true

class AccountShareInvite < ApplicationRecord
  belongs_to :account
  belongs_to :account_owner, class_name: 'User'

  validates :invitee_email, presence: true, uniqueness: { scope: :account_id }

  enum status: { pending: 'pending', accepted: 'accepted', rejected: 'rejected' }
end
