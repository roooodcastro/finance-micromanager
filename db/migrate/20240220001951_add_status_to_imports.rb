class AddStatusToImports < ActiveRecord::Migration[7.1]
  def change
    add_column :imports, :status, :string, null: false, default: 'in_progress'
  end
end
