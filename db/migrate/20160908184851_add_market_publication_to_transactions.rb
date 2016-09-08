class AddMarketPublicationToTransactions < ActiveRecord::Migration
  def change
    add_column :declined_credit_card_transactions, :market_publication_id, :integer
  end
end
