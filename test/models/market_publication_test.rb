require 'test_helper'

class MarketPublicationTest < ActiveSupport::TestCase
  def setup
    @sites = VINDICIA_SELECT_SITES
    @pub_sorted_sites = @sites.sort_by { |site| site[:pub_code] }
    @gci_sorted_sites = @sites.sort_by { |site| site[:gci_unit] }
  end

  class TestAllMethod < MarketPublicationTest
    test "::all method returns the VINDICIA_SELECT_SITES sorted by pub code" do
      assert_equal MarketPublication.all, @pub_sorted_sites
    end

    test "::all method can also sort by gci unit" do
      assert_equal MarketPublication.all(sort_by: :gci_unit), @gci_sorted_sites
    end

    test "::all sorts by pub code if invalid sorting parameter is passed" do
      assert_equal MarketPublication.all(sort_by: :not_valid), @pub_sorted_sites
    end
  end
end
