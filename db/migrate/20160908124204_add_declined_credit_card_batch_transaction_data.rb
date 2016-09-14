class AddDeclinedCreditCardBatchTransactionData < ActiveRecord::Migration
  def change
    add_column :declined_credit_card_batches, :start_keys, :string
    add_column :declined_credit_card_batches, :end_keys, :string
    add_column :declined_credit_card_batches, :pub_code, :string
    add_column :declined_credit_card_batches, :gci_unit, :string
  end
end
