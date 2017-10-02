require 'test_helper'

class DeclinedBatchesTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @declined_batches = DeclinedBatches.new
  end

  class IncludeMarketsAndPub < DeclinedBatchesTest
    test "it should return all the MarketPublications" do
      assert_equal MarketPublication.all.to_a, DeclinedBatches.include_markets_and_pub.to_a
    end
  end

  test "it should submit a job for later processing" do
    assert_enqueued_with(job: DeclinedBatchesJob) do
      DeclinedBatches.submit_card_batch_job([OpenStruct.new(:batch_keys => "123")],
        market_publications(:one))
    end
  end

  class DeclinedCreditCardBatchClass < DeclinedBatchesTest
    # Tests
  end
end
