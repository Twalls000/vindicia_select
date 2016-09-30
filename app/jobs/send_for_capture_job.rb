class SendForCaptureJob < ActiveJob::Base
  queue_as :send_for_capture

  def perform(transactions)
    Rails.logger.error("Starting the SendForCaptureJob #{Time.now}")
    SendForCapture.send_transactions_for_capture(transactions)
    Rails.logger.error("Completing the SendForCaptureJob #{Time.now}")
  end
end
