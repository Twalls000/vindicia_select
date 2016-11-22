class DeclinedBatchesJob < JobBase
  queue_as :create_declined_batches

  def perform(declined_batches_id)
    DeclinedBatches.create_declined_batch(declined_batches_id)
  end
end
