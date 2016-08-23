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

ActiveRecord::Schema.define(version: 20160823133453) do

  create_table "credit_card_batches", force: :cascade do |t|
    t.string   "status"
    t.datetime "run_timestamp"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "credit_card_transactions", force: :cascade do |t|
    t.string   "status"
    t.date     "credit_card_expiration_date"
    t.string   "account_holder_name"
    t.string   "billing_address_line_1"
    t.string   "billing_address_line_2"
    t.string   "billing_address_line_3"
    t.string   "billing_addr_city"
    t.string   "billing_address_county"
    t.string   "billing_address_district"
    t.string   "billing_address_postal_code"
    t.string   "billing_address_country"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "declined_credit_card_batches", force: :cascade do |t|
    t.string   "status"
    t.datetime "run_timestamp"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
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
    t.integer  "customer_id"
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
    t.string   "name_values"
    t.integer  "declined_credit_card_batch_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "market_publications", force: :cascade do |t|
    t.string   "gci_unit"
    t.string   "pub_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
