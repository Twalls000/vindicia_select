class AddLockVersionToDeclinedCreditCardTransaction < ActiveRecord::Migration
  def change
    add_column :declined_credit_card_transactions, :lock_version, :integer
  end
end
