require 'test_helper'

class MarketPublicationTest < ActiveSupport::TestCase
  def setup
    @market_publication = market_publications(:one)
  end

  class TestAllMethod < MarketPublicationTest
    test "ok" do
      assert_equal true, @market_publication.valid?
    end
    test "not ok gci unit and pub code" do
      @market_publication.gci_unit = "999"
      @market_publication.pub_code = "GN"
      assert_not @market_publication.valid?
      @market_publication.gci_unit = "9999"
      @market_publication.pub_code = "G"
      assert_not @market_publication.valid?
    end
    test "not ok dates" do
      @market_publication.start_last_range = Time.now + 5.hours
      assert_not @market_publication.valid?
    end
    test "not ok uniqueness" do
      mkt = MarketPublication.new(@market_publication.attributes.except("id"))
      assert_not mkt.valid?
    end
  end
end
