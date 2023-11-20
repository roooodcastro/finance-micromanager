# frozen_string_literal: true

class AccountShareInvitesController < AbstractAuthenticatedController
  before_action :set_invite, only: %i[destroy]

  def index
    account_share_invites_given = current_user.account_share_invites_given.as_json

    render json: camelize_props(account_share_invites_given:)
  end

  def create
    account = current_user.account_share_invites_given.new(account_share_invite_params)

    return redirect_to accounts_path, success: t('.success') if account.save

    flash.now[:error] = t('.error', name: account.display_name, error: account.errors.full_messages.join(', '))
    render inertia: 'accounts/New', props: { account: camelize_props(account.as_json) }
  end

  def destroy
    @invite.cancelled!

    redirect_to accounts_path, success: t('.success')
  end

  private

  def set_invite
    @invite = current_user.account_share_invites_given.find(params[:id])
  end

  def account_share_invite_params
    params.require(:account_share_invite).permit(:account_id, :invitee_email).merge(account_owner: current_user)
  end
end
