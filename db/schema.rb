# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_05_08_132657) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "imports", force: :cascade do |t|
    t.string "source", limit: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "raw_import_name", limit: 100
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "EUR", null: false
    t.date "transaction_date", null: false
    t.bigint "import_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["amount_cents"], name: "index_transactions_on_amount_cents"
    t.index ["import_id"], name: "index_transactions_on_import_id"
    t.index ["name"], name: "index_transactions_on_name"
    t.index ["transaction_date"], name: "index_transactions_on_transaction_date"
  end

  add_foreign_key "transactions", "imports"
end
