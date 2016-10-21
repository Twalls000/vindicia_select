require 'test_helper'

class SendForCaptureTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  def setup
    @send_for_capture = SendForCapture.new
  end

  class GetNextBatch < SendForCaptureTest
    test "the next batch can be nil" do
      DeclinedCreditCardTransaction.stub(:oldest_unsent, []) do
        assert_nil SendForCapture.get_next_batch
      end
    end

    test 'the next batch can not be nil' do
      mp = MarketPublication.new
      trans = MiniTest::Mock.new
      trans.expect(:try, mp, [:market_publication])
      DeclinedCreditCardTransaction.stub(:oldest_unsent, [trans]) do
        assert_equal mp, SendForCapture.get_next_batch
      end
    end
  end
  class Process < SendForCaptureTest
    test "it should submit a job for later processing" do
      assert_enqueued_with(job: SendForCaptureJob) do
        SendForCapture.submit_send_for_capture_job(market_publications(:one))
      end
    end
  end

  class SendTransactionsForCapture < SendForCaptureTest
    # Tests
  end
end
