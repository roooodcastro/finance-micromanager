# frozen_string_literal: true

class ProfileShareInvite < ApplicationRecord
  belongs_to :profile
  belongs_to :profile_owner, class_name: 'User'

  has_one :invitee, class_name: 'User', foreign_key: :email, primary_key: :invitee_email,
          dependent: nil, inverse_of: :profile_share_invites_received

  validates :invitee_email, presence: true, uniqueness: { scope: :profile_id }

  enum status: { pending: 'pending', accepted: 'accepted', rejected: 'rejected', cancelled: 'cancelled' }

  def self.new_invite(profile_owner:, profile_id:, invitee_email:)
    invite = find_or_initialize_by(
      profile_owner: profile_owner,
      profile_id:    profile_id,
      invitee_email: invitee_email,
      status:        :cancelled
    )

    invite.status = :pending
    invite
  end

  def as_json(*)
    super(except: %w[created_at updated_at]).merge(profile: profile.as_json, profile_owner: profile_owner.as_json)
  end

  def accept!
    transaction do
      accepted!
      ProfileShare.create!(profile: profile, user: invitee)
    end
  end
end
