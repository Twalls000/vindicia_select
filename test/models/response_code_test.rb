require 'test_helper'

class ResponseCodeTest < ActiveSupport::TestCase
  class OnLoookup < ResponseCodeTest
    test "lookup all response codes test found" do
      ResponseCode::CODES.each do |code,result|
        assert_not_equal code, ResponseCode.translate_code(code)
      end
    end
    test "lookup response code test adjusted found" do
      assert_equal "530", ResponseCode.translate_code("5")
    end
    test "lookup response numeric code test adjusted found" do
      assert_equal "530", ResponseCode.translate_code(5)
    end
    test "lookup response code with padding test adjusted found" do
      assert_equal "530", ResponseCode.translate_code("5 ")
      assert_equal "530", ResponseCode.translate_code(" 5")
    end
  end
end
