# frozen_string_literal: true

class WalletShareInvitesSentController < AbstractAuthenticatedController
  def index
    wallet_share_invites = current_user.wallet_share_invites_sent.pending.as_json

    render json: camelize_props(wallet_share_invites:)
  end

  def create
    wallet_share_invite = WalletShareInvite.new_invite(**wallet_share_invite_params.to_h.symbolize_keys)
    message_params      = {
      wallet_name: wallet_share_invite.wallet&.display_name,
      invitee:     wallet_share_invite.invitee_email
    }

    if wallet_share_invite.save
      WalletShareMailer.wallet_share_invite_sent(wallet_share_invite.id).deliver_later

      flash[:success] = t('.success', **message_params)
    else
      flash[:error] = t('.error', **message_params.merge(error: wallet_share_invite.errors.full_messages.join(', ')))
    end

    redirect_to wallets_path
  end

  def destroy
    invite = current_user.wallet_share_invites_sent.find(params[:id])
    invite.cancelled!

    render json: camelize_props(wallet_share_invite: invite.as_json)
  rescue ActiveRecord::ActiveRecordError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def wallet_share_invite_params
    params.require(:wallet_share_invite).permit(:wallet_id, :invitee_email).merge(wallet_owner: current_user)
  end
end
