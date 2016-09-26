class RenameDivisionNumber < ActiveRecord::Migration
  def change
    rename_column :declined_credit_card_transactions, :division_number, :division_id
  end
end
