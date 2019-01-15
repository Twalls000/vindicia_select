class QueueTransactionForSendForCaptureJob < JobBase
  queue_as :queue_transaction_for_send_for_capture

  def perform(transaction)
    transaction.queue_for_send!
  end
end
