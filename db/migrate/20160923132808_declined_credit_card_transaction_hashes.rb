class DeclinedCreditCardTransactionHashes < ActiveRecord::Migration
  def change
    add_column :declined_credit_card_transactions, :named_values, :text
  end
end
