class CreateAuditTrails < ActiveRecord::Migration
  def change
    create_table :audit_trails do |t|
      t.string :event
      t.integer :declined_credit_card_transaction_id
      t.text :changed_values

      t.timestamps null: false
    end
  end
end
