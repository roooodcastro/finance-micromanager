class CreateImportNames < ActiveRecord::Migration[7.1]
  def change
    create_table :import_names, id: :uuid do |t|
      t.references :profile, type: :uuid,foreign_key: true, index: true, null: false

      t.string :import_name, null: false
      t.string :transaction_name, null: false

      t.timestamps
    end

    add_index :import_names, %i[profile_id import_name], unique: true
  end
end
