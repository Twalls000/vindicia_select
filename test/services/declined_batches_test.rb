require 'test_helper'

class DeclinedBatchesTest < ActiveSupport::TestCase
  def setup
    @declined_batches = DeclinedBatches.new
  end

  class IncludeMarketsAndPub < DeclinedBatchesTest
    test "it should return all the MarketPublications" do
      assert_equal DeclinedBatches.include_markets_and_pub, MarketPublication.all
    end
  end

  class Process < DeclinedBatchesTest
    # Tests
  end

  class DeclinedCreditCardBatchClass < DeclinedBatchesTest
    # Tests
  end
end
