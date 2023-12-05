class RenameWalletIdColumnsToProfileId < ActiveRecord::Migration[7.0]
  def change
    rename_column :profile_shares, :wallet_id, :profile_id
    rename_column :profile_share_invites, :wallet_id, :profile_id
    rename_column :profile_share_invites, :wallet_owner_id, :profile_owner_id
    rename_column :users, :default_wallet_id, :default_profile_id
    rename_column :transactions, :wallet_id, :profile_id
    rename_column :imports, :wallet_id, :profile_id
    rename_column :categories, :wallet_id, :profile_id
  end
end
