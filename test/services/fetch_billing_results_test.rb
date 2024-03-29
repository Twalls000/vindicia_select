require 'test_helper'

class FetchBillingResultsTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  class Initialize < FetchBillingResultsTest
    test 'an error is thrown if no start_timestamp is passed' do
      exception = assert_raises(KeyError) { FetchBillingResults.new }
      assert_equal "key not found: :start_timestamp", exception.message
    end

    test 'an error is thrown if no page_size is passed' do
      exception = assert_raises(KeyError) { FetchBillingResults.new(start_timestamp: DateTime.now) }
      assert_equal "key not found: :page_size", exception.message
    end

    test 'the default value for end_timestamp is nil' do
      fbr = FetchBillingResults.new(start_timestamp: DateTime.now, page_size: 10)
      assert_nil fbr.end_timestamp
    end
  end

  class Process < FetchBillingResultsTest
    test "it should submit a job for later processing" do
      assert_enqueued_with(job: FetchBillingResultsJob) do
        FetchBillingResults.process
      end
    end
  end

  class FetchBillingResultsMethod < FetchBillingResultsTest
    # Tests
  end

  class ProcessResponse < FetchBillingResultsTest
    # Tests
  end
end
