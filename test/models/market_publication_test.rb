require 'test_helper'

class MarketPublicationTest < ActiveSupport::TestCase
  def setup
    @market_publication = MarketPublication.new
  end

  class TestAllMethod < MarketPublicationTest
    test "ok" do
      @market_publication.gci_unit = "9999"
      @market_publication.pub_code = "GN"
      assert_equal true, @market_publication.valid?
    end
    test "not ok" do
      assert_not @market_publication.valid?
      @market_publication.gci_unit = "999"
      @market_publication.pub_code = "GN"
      assert_not @market_publication.valid?
      @market_publication.gci_unit = "9999"
      @market_publication.pub_code = "G"
      assert_not @market_publication.valid?
    end
  end
end
