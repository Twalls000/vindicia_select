require 'test_helper'

class QueueTransactionForSendForCaptureJobTest < ActiveJob::TestCase
  def setup
    @trans = declined_credit_card_transactions(:handle_in_error).dup
    @trans.save
  end

  test "sets transaction status to entry to be picked up by automated process" do
    assert @trans.in_error?
    QueueTransactionForSendForCaptureJob.perform_now(@trans)
    assert @trans.reload.entry?
  end
end
