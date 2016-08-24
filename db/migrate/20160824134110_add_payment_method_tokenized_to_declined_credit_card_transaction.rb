class AddPaymentMethodTokenizedToDeclinedCreditCardTransaction < ActiveRecord::Migration
  def change
    add_column :declined_credit_card_transactions, :payment_method_tokenized, :boolean
  end
end
