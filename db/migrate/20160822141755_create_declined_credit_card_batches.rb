class CreateDeclinedCreditCardBatches < ActiveRecord::Migration
  def change
    create_table :declined_credit_card_batches do |t|
      t.string :gci_unit
      t.string :pub_code
      t.string :status
      t.string :end_keys
      t.string :start_keys
      t.timestamp :create_start_timestamp
      t.timestamp :create_end_timestamp

      t.timestamps null: false
    end
  end
end
