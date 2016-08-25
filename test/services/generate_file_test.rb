require 'test_helper'

class GenerateFileTest < ActiveSupport::TestCase
  def setup
    @gen_file = GenerateFile.new
  end

  class OnInitialize < GenerateFileTest
    test "run_date is set to today" do
      assert_equal @gen_file.run_date, Date.today
    end
  end

  class IncludeMarketsAndPub < GenerateFileTest
    test "it should return all the MarketPublications" do
      assert_equal @gen_file.include_markets_and_pub, MarketPublication.all
    end
  end

  class Process < GenerateFileTest
    # Tests
  end

  class DeclinedCreditCardBatchClass < GenerateFileTest
    test "it should create a new declined credit card batch" do
      assert_instance_of DeclinedCreditCardBatch, @gen_file.start_batch
    end
  end
end
