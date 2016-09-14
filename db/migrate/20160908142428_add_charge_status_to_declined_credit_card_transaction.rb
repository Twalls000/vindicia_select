class AddChargeStatusToDeclinedCreditCardTransaction < ActiveRecord::Migration
  def change
    add_column :declined_credit_card_transactions, :charge_status, :string
  end
end
