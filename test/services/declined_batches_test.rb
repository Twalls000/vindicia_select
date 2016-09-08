require 'test_helper'

class DeclinedBatchesTest < ActiveSupport::TestCase
  def setup
    @declined_batches = DeclinedBatches.new
  end

  class OnInitialize < DeclinedBatchesTest
    test "run_date is set to today" do
      assert_equal @declined_batches.run_date, Date.today
    end
  end

  class IncludeMarketsAndPub < DeclinedBatchesTest
    test "it should return all the MarketPublications" do
      assert_equal @declined_batches.include_markets_and_pub, MarketPublication.all
    end
  end

  class Process < DeclinedBatchesTest
    # Tests
  end

  class DeclinedCreditCardBatchClass < DeclinedBatchesTest
    # Tests
  end
end
