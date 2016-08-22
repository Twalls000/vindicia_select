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

ActiveRecord::Schema.define(version: 20160822142413) do

  create_table "declined_credit_card_batches", force: :cascade do |t|
    t.string   "status",        limit: 255
    t.datetime "run_timestamp"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
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
    t.integer  "customer_id",                   limit: 4
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
    t.string   "name_values",                   limit: 255
    t.integer  "declined_credit_card_batch_id", limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

end
