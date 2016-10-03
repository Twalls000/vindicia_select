class FailedBillingResultsJob < ActiveJob::Base
  queue_as :failed_billing_results

  def perform
    Rails.logger.warn("Starting the FailedBillingResultsJob #{Time.now}")
    # Get the definitions to pull the data back
    FailedBillingResults.failed_billing_results
    Rails.logger.warn("Completing the FailedBillingResultsJob #{Time.now}")
  end
end
