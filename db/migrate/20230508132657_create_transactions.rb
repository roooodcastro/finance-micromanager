# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.string :name, null: false, index: true, limit: 100
      t.string :raw_import_name, limit: 100
      t.monetize :amount
      t.date :transaction_date, null: false, index: true
      t.references :import, foreign_key: true, index: true

      t.timestamps
    end

    add_index :transactions, :amount_cents
  end
end
