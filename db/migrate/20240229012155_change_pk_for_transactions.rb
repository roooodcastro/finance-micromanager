class ChangePkForTransactions < ActiveRecord::Migration[7.1]
  def change
    add_column :transactions, :uuid, :uuid, default: "gen_random_uuid()", null: false

    add_column :reconciliations, :balance_correction_transaction_uuid, :uuid

    execute <<~SQL.squish
      UPDATE reconciliations
      SET balance_correction_transaction_uuid = transactions.uuid
      FROM transactions WHERE transactions.id = reconciliations.balance_correction_transaction_id
    SQL

    remove_reference :reconciliations, :balance_correction_transaction

    change_table :transactions do |t|
      t.remove :id
      t.rename :uuid, :id
    end

    change_table :reconciliations do |t|
      t.rename :balance_correction_transaction_uuid, :balance_correction_transaction_id
    end

    execute 'ALTER TABLE transactions ADD PRIMARY KEY (id);'

    add_foreign_key :reconciliations, :transactions, column: :balance_correction_transaction_id
  end
end
