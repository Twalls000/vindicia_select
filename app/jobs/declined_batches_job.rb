class DeclinedBatchesJob < ActiveJob::Base
  queue_as :create_declined_batches

  around_perform do |job, block|
    Rails.logger.warn("Starting the DeclinedBatchesJob #{Time.now}")

    begin
      block.call
    rescue => e
      # Send email
      puts "An email was sent!"
      raise e
    end

    Rails.logger.warn("Completing the DeclinedBatchesJob #{Time.now}")
  end

  def perform(declined_batches_id)
    DeclinedBatches.create_declined_batch(declined_batches_id)
  end
end
