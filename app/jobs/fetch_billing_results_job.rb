class FetchBillingResultsJob < ActiveJob::Base
  queue_as :fetch_billing_results

  def perform
    # TODO do we add these to the submission? Make them scalable?
    fetch_billing_results = FetchBillingResults.new(page_size:10, 
      start_timestamp:Time.now-4.days, end_timestamp:Time.now-1.days)
    fetch_billing_results.fetch_billing_results
  end
end
