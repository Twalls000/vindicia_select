class FetchBillingResults

  TRANSACTION_STATUS_TYPE = ["BillingNotAttempted", "Cancelled", "Captured", "Failed", "Refunded"]
  #
  # This section of code is to create the batches for the background
  # processor to later track every failed credit card in the centralized
  # table.
  #
  def self.process
  end

  #
  # This section will take a defined batch of credit cards and add to the
  # centralized table.
  #
  def self.fetch_billing_results
  end
  # Call api. select through transaction objects
  # check "status" of each for above
  # if recovered then tell Genesys
  # if anything else then tell Genesys
end
