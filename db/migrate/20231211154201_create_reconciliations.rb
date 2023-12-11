class CreateReconciliations < ActiveRecord::Migration[7.0]
  def change
    create_table :reconciliations, id: :uuid do |t|
      t.references :profile, type: :uuid, null: false, index: true, foreign_key: true
      t.references :balance_correction_transaction, index: true, foreign_key: { to_table: :transactions }
      t.date :date, null: false
      t.string :status, null: false, limit: 20
      t.monetize :difference_amount, currency: { present: false }
      t.monetize :final_balance_amount, currency: { present: false }

      t.timestamps
    end
  end
end
