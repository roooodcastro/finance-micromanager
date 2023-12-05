# frozen_string_literal: true

class ProfileShareMailer < ApplicationMailer
  def profile_share_invite_sent(profile_share_invite_id)
    @profile_share_invite = ProfileShareInvite.find(profile_share_invite_id)
    @inviter              = @profile_share_invite.profile_owner
    @invitee              = User.find_by(email: @profile_share_invite.invitee_email)

    mail_headers = {
      subject: I18n.t('profile_share_mailer.profile_share_invite_sent.subject', inviter: @inviter.display_name),
      to:      @profile_share_invite.invitee_email
    }

    mail(mail_headers)
  end
end
