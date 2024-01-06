class AddLocaleToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :locale, :string, limit: 5, null: false, default: 'en'
  end
end
