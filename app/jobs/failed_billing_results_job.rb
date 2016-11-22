class FailedBillingResultsJob < JobBase
  queue_as :failed_billing_results

  def perform
    # Get the definitions to pull the data back
    FailedBillingResults.failed_billing_results
  end
end
