class DeclinedBatchesJob < ActiveJob::Base
  queue_as :create_declined_batches

  def perform(declined_batches_id)
    Rails.logger.warn("Starting the DeclinedBatchesJob #{Time.now}")
    DeclinedBatches.create_declined_batch(declined_batches_id)
    Rails.logger.warn("Completing the DeclinedBatchesJob #{Time.now}")
  end
end
