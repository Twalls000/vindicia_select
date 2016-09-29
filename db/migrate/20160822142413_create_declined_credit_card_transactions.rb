class CreateDeclinedCreditCardTransactions < ActiveRecord::Migration
  def change
    create_table :declined_credit_card_transactions do |t|
      t.timestamp :declined_timestamp
      t.float :amount
      t.string :currency
      t.string :status
      t.string :division_number
      t.string :merchant_transaction_id
      t.string :select_transaction_id
      t.string :subscription_id
      t.date :subscription_start_date
      t.date :previous_billing_date
      t.integer :previous_billing_count
      t.integer :customer_id
      t.string :payment_method
      t.string :credit_card_number
      t.string :credit_card_account_hash
      t.date :credit_card_expiration_date
      t.string :account_holder_name
      t.string :billing_address_line1
      t.string :billing_address_line2
      t.string :billing_address_line3
      t.string :billing_addr_city
      t.string :billing_address_county
      t.string :billing_address_district
      t.string :billing_address_postal_code
      t.string :billing_address_country
      t.string :affiliate_id
      t.string :affiliate_sub_id
      t.string :billing_statement_identifier
      t.string :auth_code
      t.string :avs_code
      t.string :cvn_code
      t.text :name_values
      t.string :charge_status
      t.string :gci_unit
      t.string :pub_code
      t.integer :account_number
      t.integer :batch_date
      t.string :batch_id
      t.belongs_to :declined_credit_card_batch
      t.timestamps null: false
    end
  end
end
