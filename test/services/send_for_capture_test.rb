require 'test_helper'

class SendForCaptureTest < ActiveSupport::TestCase
  def setup
    @send_for_capture = SendForCapture.new
  end

  # bogus first test
  class ClassSendForCaptureTest < SendForCaptureTest
    test "it should be a class" do
      assert_equal @send_for_capture.class, SendForCapture
    end
  end
  class GetNextBatch < SendForCaptureTest
    test "the next batch can be nil" do
      assert_nil SendForCapture.get_next_batch
    end
  end
  class Process < SendForCaptureTest
    # Tests
  end

  class SendForCaptureTestClass < SendForCaptureTest
    # Tests
  end
end
