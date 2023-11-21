# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/account_share_mailer
class AccountShareMailerPreview < ActionMailer::Preview
  def account_share_invite_sent
    AccountShareMailer.account_share_invite_sent(AccountShareInvite.last.id)
  end
end
