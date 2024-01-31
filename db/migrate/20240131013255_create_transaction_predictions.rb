class CreateTransactionPredictions < ActiveRecord::Migration[7.1]
  def change
    create_table :transaction_predictions, id: :uuid do |t|
      t.references :profile, type: :uuid, foreign_key: true, index: true, null: false

      t.string :name, null: false, limit: 50
      t.string :rules_json, null: false, limit: 2000

      t.datetime :disabled_at
      t.references :disabled_by, type: :uuid, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
