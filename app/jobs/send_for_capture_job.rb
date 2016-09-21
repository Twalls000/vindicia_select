class SendForCaptureJob < ActiveJob::Base
  queue_as :send_for_capture

  def perform(transactions)
    #transactions.each do |t|
      SendForCapture.send_transactions_for_capture(transactions)
    #end
  end
end
