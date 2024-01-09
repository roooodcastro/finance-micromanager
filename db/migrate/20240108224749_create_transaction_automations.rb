class CreateTransactionAutomations < ActiveRecord::Migration[7.0]
  def change
    create_table :transaction_automations, id: :uuid do |t|
      t.references :profile, type: :uuid,foreign_key: true, index: true, null: false

      t.string :schedule_type, null: false
      t.integer :schedule_interval, null: false
      t.date :next_schedule_date, null: false

      t.string :transaction_name, null: false, limit: 100
      t.monetize :transaction_amount, currency: { present: false }
      t.references :transaction_category, type: :uuid, null: false, foreign_key: { to_table: :categories }
      t.references :transaction_wallet, type: :uuid, null: true, foreign_key: { to_table: :wallets }

      t.datetime :disabled_at
      t.references :disabled_by, type: :uuid, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
