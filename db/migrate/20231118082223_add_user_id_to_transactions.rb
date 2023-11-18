class AddUserIdToTransactions < ActiveRecord::Migration[7.0]
  def up
    add_reference :transactions, :created_by,
                  index: true, foreign_key: { to_table: :users }, type: :uuid

    add_reference :transactions, :updated_by,
                  index: true, foreign_key: { to_table: :users }, type: :uuid

    execute(<<~SQL
      UPDATE transactions AS t SET created_by_id = a.user_id, updated_by_id = a.user_id
      FROM accounts AS a
      WHERE a.id = t.account_id
    SQL
    )

    change_column :transactions, :created_by_id, :uuid, null: false
    change_column :transactions, :updated_by_id, :uuid, null: false
  end

  def down
    remove_column :transactions, :created_by_id
    remove_column :transactions, :updated_by_id
  end
end
