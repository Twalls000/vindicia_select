class SendForCaptureJob < ActiveJob::Base
  queue_as :send_for_capture

  def perform(*args)
    # Do something later
  end
end
