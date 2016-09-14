class AddToDeclinedCreditCardTransaction < ActiveRecord::Migration
  def change
    add_column :declined_credit_card_transactions, :gci_unit, :string
    add_column :declined_credit_card_transactions, :pub_code, :string
    add_column :declined_credit_card_transactions, :batch_id, :string
    add_column :declined_credit_card_transactions, :batch_date, :integer
    add_column :declined_credit_card_transactions, :account_number, :integer
  end
end
