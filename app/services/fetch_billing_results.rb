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
      process_response(response) unless response.empty?
      @page+=1
    end until response.empty?
  end

  def process_response response
    if response.is_a?(Array) && response.map(&:class).include?(Vindicia::Transaction)
      mtids = response.select { |r| r.is_a? Vindicia::Transaction }.map(&:merchant_transaction_id)
      declined_cards = DeclinedCreditCardTransaction.find_by_merchant_transaction_id(mtids)
      declined_cards.each do |declined_card|
        transaction = response.select { |r| r.merchant_transaction_id == declined_card.merchant_transaction_id }.first
        if transaction && declined_card.pending?
          declined_card.name_values = transaction.name_values
          declined_card.charge_status = transaction.status
          declined_card.select_transaction_id = transaction.select_transaction_id
          declined_card.auth_code = transaction.auth_code
          declined_card.fetch_soap_id = transaction.soap_id
          declined_card.status_update

          declined_card.failed_to_send_to_genesys unless DeclinedCreditCard.send_transaction(declined_card)
          declined_card.save
        end
      end
    end
  end
end
