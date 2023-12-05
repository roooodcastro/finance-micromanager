class RenameWalletShareInviteToProfileShareInvite < ActiveRecord::Migration[7.0]
  def change
    rename_table :wallet_share_invites, :profile_share_invites
  end
end
