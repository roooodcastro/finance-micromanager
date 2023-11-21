# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/wallet_share_mailer
class WalletShareMailerPreview < ActionMailer::Preview
  def wallet_share_invite_sent
    WalletShareMailer.wallet_share_invite_sent(WalletShareInvite.last.id)
  end
end
