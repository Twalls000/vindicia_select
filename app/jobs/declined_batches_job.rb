class DeclinedBatchesJob < ActiveJob::Base
  queue_as :create_declined_batches

  def perform(*args)
    
  end
end
