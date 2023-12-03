# frozen_string_literal: true

class WalletShareMailer < ApplicationMailer
  def wallet_share_invite_sent(wallet_share_invite_id)
    @wallet_share_invite = WalletShareInvite.find(wallet_share_invite_id)
    @inviter             = @wallet_share_invite.wallet_owner
    @invitee             = User.find_by(email: @wallet_share_invite.invitee_email)

    mail_headers = {
      subject: I18n.t('wallet_share_mailer.wallet_share_invite_sent.subject', inviter: @inviter.display_name),
      to:      @wallet_share_invite.invitee_email
    }

    mail(mail_headers)
  end
end
