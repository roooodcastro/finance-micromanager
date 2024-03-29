# frozen_string_literal: true

class ProfileShareInvitesReceivedController < AbstractAuthenticatedController
  before_action :set_invite, only: %i[update destroy]

  def index
    profile_share_invites = current_user.profile_share_invites_received.pending.as_json

    render json: camelize_props(profile_share_invites:)
  end

  def update
    @invite.accept!

    render json: camelize_props(profile_share_invite: @invite.as_json)
  rescue ActiveRecord::ActiveRecordError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def destroy
    @invite.rejected!

    render json: camelize_props(profile_share_invite: @invite.as_json)
  rescue ActiveRecord::ActiveRecordError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_invite
    @invite = current_user.profile_share_invites_received.find(params[:id])
  end
end
