class FetchBillingResults

  TRANSACTION_STATUS_TYPE = ["BillingNotAttempted", "Cancelled", "Captured", "Failed", "Refunded"]
  attr_accessor :start_timestamp, :end_timestamp, :page, :page_size

  # A Valid object must have the start time, and page size
  # The page may default to 0, if not provided.
  def initialize(args = {})
    @start_timestamp = args.fetch(:start_timestamp)
    @end_timestamp = args[:end_timestamp]
    @page = args.fetch(:page, 0)
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

  def process_response response
    if response.is_a?(Array) && response.map(&:class).include?(Vindicia::Transaction)
      response.select { |r| r.is_a? Vindicia::Transaction }.each do |transaction|
        declined_card = DeclinedCreditCardTransaction.
          find_by_merchant_transaction_id(transaction.merchant_transaction_id).first
        if declined_card
          declined_card.named_values = transaction.named_values
          declined_card.charge_status = transaction.status
          declined_card.select_transaction_id = transaction.select_transaction_id
          declined_card.auth_code = transaction.auth_code
          declined_card.status_update
          declined_card.save
        end
      end
    end
  end
end
