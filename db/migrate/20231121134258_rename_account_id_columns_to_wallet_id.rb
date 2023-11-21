class RenameAccountIdColumnsToWalletId < ActiveRecord::Migration[7.0]
  def change
    rename_column :wallet_shares, :account_id, :wallet_id
    rename_column :wallet_share_invites, :account_id, :wallet_id
    rename_column :wallet_share_invites, :account_owner_id, :wallet_owner_id
    rename_column :users, :default_account_id, :default_wallet_id
    rename_column :transactions, :account_id, :wallet_id
    rename_column :imports, :account_id, :wallet_id
    rename_column :categories, :account_id, :wallet_id
  end
end
