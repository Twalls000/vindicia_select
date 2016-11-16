class FailedBillingResultsJob < ActiveJob::Base
  queue_as :failed_billing_results

  around_perform do |job, block|
    Rails.logger.warn("Starting the FailedBillingResultsJob #{Time.now}")

    begin
      block.call
    rescue => e
      # Send email
      raise e
    end

    Rails.logger.warn("Completing the FailedBillingResultsJob #{Time.now}")
  end

  def perform
    # Get the definitions to pull the data back
    FailedBillingResults.failed_billing_results
  end
end
