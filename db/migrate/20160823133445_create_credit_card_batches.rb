class CreateCreditCardBatches < ActiveRecord::Migration
  def change
    create_table :credit_card_batches do |t|
      t.string :status
      t.timestamp :run_timestamp

      t.timestamps null: false
    end
  end
end
