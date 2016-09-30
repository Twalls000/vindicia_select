class FailedBillingResultsJob < ActiveJob::Base
  queue_as :failed_billing_results

  def perform
    Rails.logger.error("Starting the FailedBillingResultsJob #{Time.now}")
    # Get the definitions to pull the data back
    FailedBillingResults.failed_billing_results
    Rails.logger.error("Completing the FailedBillingResultsJob #{Time.now}")
  end
end
