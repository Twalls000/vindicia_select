class ChangeMarketPublications < ActiveRecord::Migration
  def change
    create_table :market_publications, :force=>true do |t|
      t.string :gci_unit
      t.string :pub_code
      t.timestamp :start_last_range
      t.timestamp :end_last_range
      t.integer :import_time_seconds
      t.integer :vindicia_batch_size
      t.timestamps null: false
    end
  end
end
