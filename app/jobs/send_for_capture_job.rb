class SendForCaptureJob < ActiveJob::Base
  queue_as :send_for_capture

  def perform(transactions)
    SendForCapture.send_transactions_for_capture(transactions)
  end
end
