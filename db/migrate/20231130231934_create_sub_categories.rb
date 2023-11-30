class CreateSubCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :sub_categories, id: :uuid do |t|
      t.references :category, type: :uuid, null: false, index: true, foreign_key: true
      t.string :name, limit: 50, null: false
      t.datetime :disabled_at
      t.references :disabled_by, type: :uuid, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
