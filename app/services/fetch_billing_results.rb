class FetchBillingResults

  TRANSACTION_STATUS_TYPE = ["BillingNotAttempted", "Cancelled", "Captured", "Failed", "Refunded"]
  attr_accessor :start_timestamp, :end_timestamp, :page, :page_size

  # A Valid object must have the start time, and page size
  # The page may default to 0, if not provided.
  def initialize(args = {})
    @start_timestamp = args.fetch(:start_timestamp)
    @end_timestamp = args.fetch(:end_timestamp)  if args[:end_timestamp]
    @page = args[:end_timestamp] ? args.fetch(:page) : 0
    @page_size = args.fetch(:page_size)
  end

  #
  # This section of code is to create the batches for the background
  # processor to later track every failed credit card in the centralized
  # table.
  #
  def self.process
    # Get the transactions and mark them for processing
    FetchBillingResultsJob.perform_later
  end

  #
  # This section will take a defined batch of credit cards and add to the
  # centralized table.
  #
  def fetch_billing_results
    begin
      response = Select.fetch_billing_results(@start_timestamp, @end_timestamp,
        @page, @page_size)
      process_response response
      @page+=1
    end until response.empty?
  end

  def process_response
    if response.is_a?(Array) && response.map(&:class).include?(Vindicia::TransactionValidationResponse)
      response.select { |r| r.is_a? Vindicia::TransactionValidationResponse }.each do |vtvr|
        trans = transactions.select { |t| t.merchant_transaction_id == vtvr.merchant_transaction_id }.first
        trans.audit_trails.build(event: "Vindicia code #{vtvr.code}: #{vtvr.description}")
        vtvr.code.to_s == "200" ? trans.send_to_vindicia : trans.error_sending_to_vindicia
        trans.save
      end
    end
  end
  # Call api. select through transaction objects
  # check "status" of each for above
  # if recovered then tell Genesys
  # if anything else then tell Genesys
end
