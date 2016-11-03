class AddYearToDeclinedCreditCardTransaction < ActiveRecord::Migration
  def change
    add_column :declined_credit_card_transactions, :year, :integer
    add_index  :declined_credit_card_transactions, :year
  end
end
