# frozen_string_literal: true

class ProfileShareInvitesSentController < AbstractAuthenticatedController
  def index
    profile_share_invites = current_user.profile_share_invites_sent.pending.as_json

    render json: camelize_props(profile_share_invites:)
  end

  def create
    profile_share_invite = ProfileShareInvite.new_invite(**profile_share_invite_params.to_h.symbolize_keys)
    message_params       = {
      profile_name: profile_share_invite.profile&.display_name,
      invitee:      profile_share_invite.invitee_email
    }

    if profile_share_invite.save
      ProfileShareMailer.profile_share_invite_sent(profile_share_invite.id).deliver_later

      flash[:success] = t('.success', **message_params)
    else
      flash[:error] = t('.error', **message_params, error: profile_share_invite.error_messages)
    end

    redirect_to profiles_path
  end

  def destroy
    invite = current_user.profile_share_invites_sent.find(params[:id])
    invite.cancelled!

    render json: camelize_props(profile_share_invite: invite.as_json)
  rescue ActiveRecord::ActiveRecordError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def profile_share_invite_params
    params.expect(profile_share_invite: %i[profile_id invitee_email]).merge(profile_owner: current_user)
  end
end
