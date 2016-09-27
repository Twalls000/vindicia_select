require 'test_helper'

class ReturnNotificationSettingTest < ActiveSupport::TestCase
    def setup
      @return_notification_setting = return_notification_settings(:one)
    end

    class OnCreation < ReturnNotificationSettingTest
      test "valid object" do
        assert_equal true, @return_notification_setting.valid?
      end
    end
end
