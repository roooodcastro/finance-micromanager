class AddDisableableFieldsToCategory < ActiveRecord::Migration[7.0]
  def change
    add_reference :categories, :disabled_by, type: :uuid, foreign_key: { to_table: :users }
  end
end
