class AddSoapIdToDeclinedCreditCardTransaction < ActiveRecord::Migration
  def change
    add_column :declined_credit_card_transactions, :soap_id, :string
  end
end
