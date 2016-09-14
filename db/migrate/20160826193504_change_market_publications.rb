class ChangeMarketPublications < ActiveRecord::Migration
  def change
    create_table :market_publications, :force=>true do |t|
      t.string :gci_unit
      t.string :pub_code
      t.string :declined_credit_card_batch_keys
      t.integer :declined_credit_card_batch_size
      t.integer :vindicia_batch_size
      t.timestamps null: false
    end
  end
end
