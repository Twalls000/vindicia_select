class CreateReturnNotificationSettings < ActiveRecord::Migration
  def change
    create_table :return_notification_settings do |t|
      t.integer :checking_number_of_days
      t.integer :range_to_check
      t.integer :page
      t.integer :days_before_failure
      t.timestamps null: false
    end
  end
end
