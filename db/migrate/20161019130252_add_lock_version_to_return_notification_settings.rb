class AddLockVersionToReturnNotificationSettings < ActiveRecord::Migration
  def change
    add_column :return_notification_settings, :lock_version, :integer
  end
end
