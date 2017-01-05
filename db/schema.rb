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

ActiveRecord::Schema.define(version: 20170105193018) do

  create_table "audit_trails", force: :cascade do |t|
    t.string   "event"
    t.integer  "declined_credit_card_transaction_id"
    t.text     "changed_values"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.text     "exception"
  end

  create_table "declined_credit_card_batches", force: :cascade do |t|
    t.string   "gci_unit"
    t.string   "pub_code"
    t.string   "status"
    t.string   "end_keys"
    t.string   "start_keys"
    t.datetime "create_start_timestamp"
    t.datetime "create_end_timestamp"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "declined_credit_card_transactions", force: :cascade do |t|
    t.datetime "declined_timestamp"
    t.float    "amount"
    t.string   "currency"
    t.string   "status"
    t.string   "division_number"
    t.string   "merchant_transaction_id"
    t.string   "select_transaction_id"
    t.string   "subscription_id"
    t.date     "subscription_start_date"
    t.date     "previous_billing_date"
    t.integer  "previous_billing_count"
    t.string   "customer_id"
    t.string   "payment_method"
    t.string   "credit_card_number"
    t.string   "credit_card_account_hash"
    t.date     "credit_card_expiration_date"
    t.string   "account_holder_name"
    t.string   "billing_address_line1"
    t.string   "billing_address_line2"
    t.string   "billing_address_line3"
    t.string   "billing_addr_city"
    t.string   "billing_address_county"
    t.string   "billing_address_district"
    t.string   "billing_address_postal_code"
    t.string   "billing_address_country"
    t.string   "affiliate_id"
    t.string   "affiliate_sub_id"
    t.string   "billing_statement_identifier"
    t.string   "auth_code"
    t.string   "avs_code"
    t.string   "cvn_code"
    t.text     "name_values"
    t.string   "charge_status"
    t.string   "gci_unit"
    t.string   "pub_code"
    t.integer  "account_number"
    t.integer  "batch_date"
    t.string   "batch_id"
    t.integer  "declined_credit_card_batch_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "payment_method_tokenized"
    t.integer  "market_publication_id"
    t.string   "payment_method_id"
    t.string   "soap_id"
    t.string   "fetch_soap_id"
    t.string   "empty_last_fetch_soap_id"
    t.integer  "year"
  end

  add_index "declined_credit_card_transactions", ["year"], name: "index_declined_credit_card_transactions_on_year"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",                      default: 0, null: false
    t.integer  "attempts",                      default: 0, null: false
    t.text     "handler",    limit: 4294967295,             null: false
    t.text     "last_error", limit: 4294967295
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"
  add_index "delayed_jobs", ["queue"], name: "delayed_jobs_queue"

  create_table "market_publications", force: :cascade do |t|
    t.string   "gci_unit"
    t.string   "pub_code"
    t.string   "declined_credit_card_batch_keys"
    t.integer  "declined_credit_card_batch_size"
    t.integer  "vindicia_batch_size"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "return_notification_settings", force: :cascade do |t|
    t.integer  "checking_number_of_days"
    t.integer  "range_to_check"
    t.integer  "page"
    t.integer  "days_before_failure"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "lock_version"
    t.integer  "fetch_page_number"
  end

  create_table "sites", force: :cascade do |t|
    t.string   "gci_unit"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
