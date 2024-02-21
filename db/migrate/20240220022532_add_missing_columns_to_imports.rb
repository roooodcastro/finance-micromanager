class AddMissingColumnsToImports < ActiveRecord::Migration[7.1]
  def change
    add_reference :imports, :wallet, type: :uuid, index: true, foreign_key: true
  end
end
