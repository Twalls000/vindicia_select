class CreateMarketPublications < ActiveRecord::Migration
  def change
    create_table :market_publications do |t|
      t.string :gci_unit
      t.string :pub_code

      t.timestamps null: false
    end
  end
end
