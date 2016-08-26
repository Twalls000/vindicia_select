class CreateVindiciaMarketPublications < ActiveRecord::Migration
  def change
    create_table :vindicia_market_publications do |t|
      t.string :gci_unit
      t.string :pub_code
      t.string :library
      t.timestamp :start_last_range
      t.timestamp :end_last_range
      t.integer :import_time_seconds
      t.integer :vindicia_batch_size
      t.timestamps null: false
    end
  end
end
