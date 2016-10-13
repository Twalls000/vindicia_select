class AddFetchSoapIdToDeclinedCreditCardTransactions < ActiveRecord::Migration
  def change
    add_column :declined_credit_card_transactions, :fetch_soap_id, :string
  end
end
