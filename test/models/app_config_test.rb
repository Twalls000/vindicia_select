require 'test_helper'

class AppConfigTest < ActiveSupport::TestCase
	test "should not allow duplicate keys" do
		config1 = AppConfig.new(key: "YTD_SUMMARY_REPORT_RECIPIENTS" )
		config1.save
		config2 = AppConfig.new(key: "YTD_SUMMARY_REPORT_RECIPIENTS" )

		assert !config2.valid?
	end
  # test "the truth" do
  #   assert true
  # end
end
