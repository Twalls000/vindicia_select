class CreateCreditCardTransactions < ActiveRecord::Migration
  def change
    create_table :credit_card_transactions do |t|
      t.string :status
      t.date   :credit_card_expiration_date
      t.string :account_holder_name
      t.string :billing_address_line_1
      t.string :billing_address_line_2
      t.string :billing_address_line_3
      t.string :billing_addr_city
      t.string :billing_address_county
      t.string :billing_address_district
      t.string :billing_address_postal_code
      t.string :billing_address_country

      t.timestamps null: false
    end
  end
end
