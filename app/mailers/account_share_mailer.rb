# frozen_string_literal: true

class AccountShareMailer < ApplicationMailer
  def account_share_invite_sent(account_share_invite_id)
    @account_share_invite = AccountShareInvite.find(account_share_invite_id)
    @inviter              = @account_share_invite.account_owner
    @invitee              = User.find_by(email: @account_share_invite.invitee_email)

    mail_headers = {
      subject: '',
      to:      @account_share_invite.invitee_email
    }

    mail(mail_headers)
  end
end
