class AddDefaultAccountIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :default_account, index: true, foreign_key: { to_table: :accounts }, type: :uuid
  end
end
