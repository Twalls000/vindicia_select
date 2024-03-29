# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180904161343) do

  create_table "app_configs", force: :cascade do |t|
    t.string   "key",        limit: 255
    t.text     "value",      limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "app_configs", ["key"], name: "index_app_configs_on_key", using: :btree

  create_table "audit_trails", force: :cascade do |t|
    t.string   "event",                               limit: 255
    t.integer  "declined_credit_card_transaction_id", limit: 4
    t.text     "changed_values",                      limit: 65535
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.text     "exception",                           limit: 65535
    t.string   "type",                                limit: 255
    t.string   "soap_id",                             limit: 255
  end

  create_table "declined_credit_card_batches", force: :cascade do |t|
    t.string   "gci_unit",               limit: 255
    t.string   "pub_code",               limit: 255
    t.string   "status",                 limit: 255
    t.string   "end_keys",               limit: 255
    t.string   "start_keys",             limit: 255
    t.datetime "create_start_timestamp"
    t.datetime "create_end_timestamp"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "declined_credit_card_transactions", force: :cascade do |t|
    t.datetime "declined_timestamp"
    t.float    "amount",                        limit: 24
    t.string   "currency",                      limit: 255
    t.string   "status",                        limit: 255
    t.string   "division_number",               limit: 255
    t.string   "merchant_transaction_id",       limit: 255
    t.string   "select_transaction_id",         limit: 255
    t.string   "subscription_id",               limit: 255
    t.date     "subscription_start_date"
    t.date     "previous_billing_date"
    t.integer  "previous_billing_count",        limit: 4
    t.string   "customer_id",                   limit: 255
    t.string   "payment_method",                limit: 255
    t.string   "credit_card_number",            limit: 255
    t.string   "credit_card_account_hash",      limit: 255
    t.date     "credit_card_expiration_date"
    t.string   "account_holder_name",           limit: 255
    t.string   "billing_address_line1",         limit: 255
    t.string   "billing_address_line2",         limit: 255
    t.string   "billing_address_line3",         limit: 255
    t.string   "billing_addr_city",             limit: 255
    t.string   "billing_address_county",        limit: 255
    t.string   "billing_address_district",      limit: 255
    t.string   "billing_address_postal_code",   limit: 255
    t.string   "billing_address_country",       limit: 255
    t.string   "affiliate_id",                  limit: 255
    t.string   "affiliate_sub_id",              limit: 255
    t.string   "billing_statement_identifier",  limit: 255
    t.string   "auth_code",                     limit: 255
    t.string   "avs_code",                      limit: 255
    t.string   "cvn_code",                      limit: 255
    t.text     "name_values",                   limit: 65535
    t.string   "charge_status",                 limit: 255
    t.string   "gci_unit",                      limit: 255
    t.string   "pub_code",                      limit: 255
    t.integer  "account_number",                limit: 4
    t.integer  "batch_date",                    limit: 4
    t.string   "batch_id",                      limit: 255
    t.integer  "declined_credit_card_batch_id", limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "payment_method_tokenized"
    t.integer  "market_publication_id",         limit: 4
    t.string   "payment_method_id",             limit: 255
    t.string   "soap_id",                       limit: 255
    t.string   "fetch_soap_id",                 limit: 255
    t.string   "empty_last_fetch_soap_id",      limit: 255
    t.integer  "year",                          limit: 4
    t.integer  "lock_version",                  limit: 4
  end

  add_index "declined_credit_card_transactions", ["year"], name: "index_declined_credit_card_transactions_on_year", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,          default: 0, null: false
    t.integer  "attempts",   limit: 4,          default: 0, null: false
    t.text     "handler",    limit: 4294967295,             null: false
    t.text     "last_error", limit: 4294967295
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  add_index "delayed_jobs", ["queue"], name: "delayed_jobs_queue", using: :btree

  create_table "genesys_connections", force: :cascade do |t|
    t.integer  "gci_unit",   limit: 4,   null: false
    t.string   "schema",     limit: 255
    t.string   "adapter",    limit: 255
    t.string   "datasource", limit: 255
    t.string   "username",   limit: 255
    t.string   "password",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "genesys_connections", ["gci_unit", "schema"], name: "index_genesys_connections_on_gci_unit_and_schema", unique: true, using: :btree

  create_table "market_publications", force: :cascade do |t|
    t.string   "gci_unit",                        limit: 255
    t.string   "pub_code",                        limit: 255
    t.string   "declined_credit_card_batch_keys", limit: 255
    t.integer  "declined_credit_card_batch_size", limit: 4
    t.integer  "vindicia_batch_size",             limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "return_notification_settings", force: :cascade do |t|
    t.integer  "checking_number_of_days", limit: 4
    t.integer  "range_to_check",          limit: 4
    t.integer  "page",                    limit: 4
    t.integer  "days_before_failure",     limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "lock_version",            limit: 4
    t.integer  "fetch_page_number",       limit: 4
  end

  create_table "sites", force: :cascade do |t|
    t.string   "gci_unit",   limit: 255
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

end
