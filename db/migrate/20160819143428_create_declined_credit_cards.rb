class CreateDeclinedCreditCards < ActiveRecord::Migration
  def change
    create_table :declined_credit_cards do |t|

      t.timestamps null: false
    end
  end
end
