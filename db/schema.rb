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

ActiveRecord::Schema[7.1].define(version: 2024_01_27_155447) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.string "color", limit: 7
    t.uuid "profile_id", null: false
    t.datetime "disabled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category_type", limit: 20, default: "user", null: false
    t.uuid "disabled_by_id"
    t.index ["disabled_by_id"], name: "index_categories_on_disabled_by_id"
    t.index ["profile_id"], name: "index_categories_on_profile_id"
  end

  create_table "imports", force: :cascade do |t|
    t.string "source", limit: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "profile_id", null: false
    t.index ["profile_id"], name: "index_imports_on_profile_id"
  end

  create_table "profile_share_invites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "profile_id", null: false
    t.uuid "profile_owner_id", null: false
    t.string "invitee_email", null: false
    t.string "status", limit: 15, default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invitee_email"], name: "index_profile_share_invites_on_invitee_email"
    t.index ["profile_id", "invitee_email"], name: "index_profile_share_invites_on_profile_id_and_invitee_email", unique: true
    t.index ["profile_id"], name: "index_profile_share_invites_on_profile_id"
    t.index ["profile_owner_id"], name: "index_profile_share_invites_on_profile_owner_id"
  end

  create_table "profile_shares", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "profile_id", null: false
    t.uuid "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_profile_shares_on_profile_id"
    t.index ["user_id"], name: "index_profile_shares_on_user_id"
  end

  create_table "profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "status", limit: 15, default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.string "currency", null: false
    t.string "name", limit: 30
    t.uuid "default_wallet_id"
    t.integer "balance_amount_cents", default: 0, null: false
    t.index ["default_wallet_id"], name: "index_profiles_on_default_wallet_id"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "reconciliations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "profile_id", null: false
    t.bigint "balance_correction_transaction_id"
    t.date "date", null: false
    t.string "status", limit: 20, null: false
    t.integer "difference_amount_cents", default: 0, null: false
    t.integer "final_balance_amount_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["balance_correction_transaction_id"], name: "index_reconciliations_on_balance_correction_transaction_id"
    t.index ["date"], name: "index_reconciliations_on_date"
    t.index ["profile_id"], name: "index_reconciliations_on_profile_id"
  end

  create_table "reconciliations_wallets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "reconciliation_id", null: false
    t.uuid "wallet_id", null: false
    t.integer "balance_amount_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reconciliation_id"], name: "index_reconciliations_wallets_on_reconciliation_id"
    t.index ["wallet_id"], name: "index_reconciliations_wallets_on_wallet_id"
  end

  create_table "subcategories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "category_id", null: false
    t.string "name", limit: 50, null: false
    t.datetime "disabled_at"
    t.uuid "disabled_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_subcategories_on_category_id"
    t.index ["disabled_by_id"], name: "index_subcategories_on_disabled_by_id"
  end

  create_table "transaction_automations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "profile_id", null: false
    t.string "schedule_type", null: false
    t.integer "schedule_interval", null: false
    t.date "next_schedule_date", null: false
    t.string "transaction_name", limit: 100, null: false
    t.integer "transaction_amount_cents", default: 0, null: false
    t.uuid "transaction_category_id", null: false
    t.uuid "transaction_wallet_id"
    t.datetime "disabled_at"
    t.uuid "disabled_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "transaction_subcategory_id"
    t.string "schedule_custom_rule", limit: 50
    t.index ["disabled_by_id"], name: "index_transaction_automations_on_disabled_by_id"
    t.index ["profile_id"], name: "index_transaction_automations_on_profile_id"
    t.index ["transaction_category_id"], name: "index_transaction_automations_on_transaction_category_id"
    t.index ["transaction_subcategory_id"], name: "index_transaction_automations_on_transaction_subcategory_id"
    t.index ["transaction_wallet_id"], name: "index_transaction_automations_on_transaction_wallet_id"
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
    t.uuid "profile_id", null: false
    t.uuid "category_id", null: false
    t.uuid "created_by_id", null: false
    t.uuid "updated_by_id", null: false
    t.uuid "subcategory_id"
    t.uuid "wallet_id"
    t.uuid "transaction_automation_id"
    t.index ["amount_cents"], name: "index_transactions_on_amount_cents"
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["created_by_id"], name: "index_transactions_on_created_by_id"
    t.index ["import_id"], name: "index_transactions_on_import_id"
    t.index ["name"], name: "index_transactions_on_name"
    t.index ["profile_id"], name: "index_transactions_on_profile_id"
    t.index ["subcategory_id"], name: "index_transactions_on_subcategory_id"
    t.index ["transaction_automation_id"], name: "index_transactions_on_transaction_automation_id"
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
    t.uuid "default_profile_id"
    t.string "locale", limit: 5, default: "en", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["default_profile_id"], name: "index_users_on_default_profile_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "wallets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "profile_id", null: false
    t.string "name", limit: 50, null: false
    t.integer "balance_cents", default: 0, null: false
    t.string "balance_currency", default: "EUR", null: false
    t.datetime "disabled_at"
    t.uuid "disabled_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["disabled_by_id"], name: "index_wallets_on_disabled_by_id"
    t.index ["profile_id"], name: "index_wallets_on_profile_id"
  end

  add_foreign_key "categories", "profiles"
  add_foreign_key "categories", "users", column: "disabled_by_id"
  add_foreign_key "imports", "profiles"
  add_foreign_key "profile_share_invites", "profiles"
  add_foreign_key "profile_share_invites", "users", column: "profile_owner_id"
  add_foreign_key "profile_shares", "profiles"
  add_foreign_key "profile_shares", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "profiles", "wallets", column: "default_wallet_id"
  add_foreign_key "reconciliations", "profiles"
  add_foreign_key "reconciliations", "transactions", column: "balance_correction_transaction_id"
  add_foreign_key "reconciliations_wallets", "reconciliations"
  add_foreign_key "reconciliations_wallets", "wallets"
  add_foreign_key "subcategories", "categories"
  add_foreign_key "subcategories", "users", column: "disabled_by_id"
  add_foreign_key "transaction_automations", "categories", column: "transaction_category_id"
  add_foreign_key "transaction_automations", "profiles"
  add_foreign_key "transaction_automations", "subcategories", column: "transaction_subcategory_id"
  add_foreign_key "transaction_automations", "users", column: "disabled_by_id"
  add_foreign_key "transaction_automations", "wallets", column: "transaction_wallet_id"
  add_foreign_key "transactions", "categories"
  add_foreign_key "transactions", "imports"
  add_foreign_key "transactions", "profiles"
  add_foreign_key "transactions", "subcategories"
  add_foreign_key "transactions", "transaction_automations"
  add_foreign_key "transactions", "users", column: "created_by_id"
  add_foreign_key "transactions", "users", column: "updated_by_id"
  add_foreign_key "transactions", "wallets"
  add_foreign_key "users", "profiles", column: "default_profile_id"
  add_foreign_key "wallets", "profiles"
  add_foreign_key "wallets", "users", column: "disabled_by_id"
end
