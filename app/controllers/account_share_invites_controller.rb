# frozen_string_literal: true

class AccountShareInvitesController < AbstractAuthenticatedController
  def index
    account_share_invites_given = current_user.account_share_invites_given.as_json

    render json: camelize_props(account_share_invites_given:)
  end

  def create
    account_share_invite = current_user.account_share_invites_given.new(account_share_invite_params)
    message_params       = {
      account_name: account_share_invite.account&.display_name,
      invitee:      account_share_invite.invitee_email
    }

    if account_share_invite.save
      AccountShareMailer.account_share_invite_sent(account_share_invite.id).deliver_later

      flash[:success] = t('.success', **message_params)
    else
      flash[:error] = t('.error', **message_params.merge(error: account_share_invite.errors.full_messages.join(', ')))
    end

    redirect_to accounts_path
  end

  def destroy
    invite = current_user.account_share_invites_given.find(params[:id])
    invite.cancelled!

    redirect_to accounts_path, success: t('.success')
  end

  private

  def account_share_invite_params
    params.require(:account_share_invite).permit(:account_id, :invitee_email).merge(account_owner: current_user)
  end
end
