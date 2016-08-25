class CreateDeclinedCreditCardBatches < ActiveRecord::Migration
  def change
    create_table :declined_credit_card_batches do |t|
      t.string :status
      t.timestamp :create_start_timestamp
      t.timestamp :create_end_timestamp

      t.timestamps null: false
    end
  end
end
