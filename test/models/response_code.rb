require 'test_helper'

class ResponseCodeTest < ActiveSupport::TestCase
  class OnLoookup < ResponseCodeTest
    test "lookup response code test a" do
      assert_equal "AA", ResponseCode.translate_code("AA")
    end
    test "lookup response code test b" do
      assert_equal "C2".ResponseCode.translate_code("507")
    end
  end
end
