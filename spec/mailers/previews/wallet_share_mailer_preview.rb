# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/profile_share_mailer
class ProfileShareMailerPreview < ActionMailer::Preview
  def profile_share_invite_sent
    ProfileShareMailer.profile_share_invite_sent(ProfileShareInvite.last.id)
  end
end
