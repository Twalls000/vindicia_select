class AddFetchPageNumberToReturnNotificationSettings < ActiveRecord::Migration
  def change
    add_column :return_notification_settings, :fetch_page_number, :integer
  end
end
