class FetchBillingResultsJob < ActiveJob::Base
  queue_as :fetch_billing_results

  def perform
    # Do something later
  end
end
