require 'test_helper'

class VindiciaMarketPublicationTest < ActiveSupport::TestCase
  def setup
    @vindicia_market_publication = VindiciaMarketPublication.new
  end

  class TestAllMethod < VindiciaMarketPublicationTest
    test "ok" do
      @vindicia_market_publication.gci_unit = "9999"
      @vindicia_market_publication.pub_code = "GN"
      @vindicia_market_publication.vindicia_batch_size = 200
      assert_equal true, @vindicia_market_publication.valid?
    end
    test "not ok" do
      assert_not @vindicia_market_publication.valid?
      @vindicia_market_publication.gci_unit = "999"
      @vindicia_market_publication.pub_code = "GN"
      assert_not @vindicia_market_publication.valid?
      @vindicia_market_publication.gci_unit = "9999"
      @vindicia_market_publication.pub_code = "G"
      assert_not @vindicia_market_publication.valid?
    end
  end
end
