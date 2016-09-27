require 'test_helper'

class FetchBillingResultsTest < ActiveSupport::TestCase
  def setup

  end

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

    test 'the default value for page is 0' do
      fbr = FetchBillingResults.new(start_timestamp: DateTime.now, page_size: 10)
      assert_equal 0, fbr.page
    end
  end

  class Process < FetchBillingResultsTest
    test 'FetchBillingResultsJob::perform_later is called' do
      # the perform_later lambda is called when
      # FetchBillingResultsJob::perform_later, the stubbed method, is called in
      # FetchBillingResults::process. This lambda changes the value of test_var,
      # thus ensuring that FetchBillingResultsJob::perform_later was called.

      test_var = false
      perform_later = ->{
        test_var = true
      }
      FetchBillingResultsJob.stub(:perform_later, perform_later) do
        FetchBillingResults.process
      end
      assert test_var
    end
  end

  class FetchBillingResultsMethod < FetchBillingResultsTest
    # Tests
  end

  class ProcessResponse < FetchBillingResultsTest
    # Tests
  end
end
