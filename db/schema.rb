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

ActiveRecord::Schema[7.0].define(version: 2023_11_30_232432) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.string "color", limit: 7
    t.uuid "wallet_id", null: false
    t.datetime "disabled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wallet_id"], name: "index_categories_on_wallet_id"
  end

  create_table "imports", force: :cascade do |t|
    t.string "source", limit: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "wallet_id", null: false
    t.index ["wallet_id"], name: "index_imports_on_wallet_id"
  end

  create_table "sub_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "category_id", null: false
    t.string "name", limit: 50, null: false
    t.datetime "disabled_at"
    t.uuid "disabled_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_sub_categories_on_category_id"
    t.index ["disabled_by_id"], name: "index_sub_categories_on_disabled_by_id"
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
    t.uuid "wallet_id", null: false
    t.uuid "category_id", null: false
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id", null: false
    t.uuid "sub_category_id"
    t.index ["amount_cents"], name: "index_transactions_on_amount_cents"
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["created_by_id"], name: "index_transactions_on_created_by_id"
    t.index ["import_id"], name: "index_transactions_on_import_id"
    t.index ["name"], name: "index_transactions_on_name"
    t.index ["sub_category_id"], name: "index_transactions_on_sub_category_id"
    t.index ["transaction_date"], name: "index_transactions_on_transaction_date"
    t.index ["updated_by_id"], name: "index_transactions_on_updated_by_id"
    t.index ["wallet_id"], name: "index_transactions_on_wallet_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "default_wallet_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["default_wallet_id"], name: "index_users_on_default_wallet_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "wallet_share_invites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "wallet_id", null: false
    t.uuid "wallet_owner_id", null: false
    t.string "invitee_email", null: false
    t.string "status", limit: 15, default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invitee_email"], name: "index_wallet_share_invites_on_invitee_email"
    t.index ["wallet_id", "invitee_email"], name: "index_wallet_share_invites_on_wallet_id_and_invitee_email", unique: true
    t.index ["wallet_id"], name: "index_wallet_share_invites_on_wallet_id"
    t.index ["wallet_owner_id"], name: "index_wallet_share_invites_on_wallet_owner_id"
  end

  create_table "wallet_shares", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "wallet_id", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wallet_shares_on_user_id"
    t.index ["wallet_id"], name: "index_wallet_shares_on_wallet_id"
  end

  create_table "wallets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "status", limit: 15, default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.string "currency", null: false
    t.string "name", limit: 30
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  add_foreign_key "categories", "wallets"
  add_foreign_key "imports", "wallets"
  add_foreign_key "sub_categories", "categories"
  add_foreign_key "sub_categories", "users", column: "disabled_by_id"
  add_foreign_key "transactions", "categories"
  add_foreign_key "transactions", "imports"
  add_foreign_key "transactions", "sub_categories"
  add_foreign_key "transactions", "users", column: "created_by_id"
  add_foreign_key "transactions", "users", column: "updated_by_id"
  add_foreign_key "transactions", "wallets"
  add_foreign_key "users", "wallets", column: "default_wallet_id"
  add_foreign_key "wallet_share_invites", "users", column: "wallet_owner_id"
  add_foreign_key "wallet_share_invites", "wallets"
  add_foreign_key "wallet_shares", "users"
  add_foreign_key "wallet_shares", "wallets"
  add_foreign_key "wallets", "users"
end
