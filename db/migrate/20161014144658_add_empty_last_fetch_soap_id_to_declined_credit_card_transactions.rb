class AddEmptyLastFetchSoapIdToDeclinedCreditCardTransactions < ActiveRecord::Migration
  def change
    add_column :declined_credit_card_transactions, :empty_last_fetch_soap_id, :string
  end
end
