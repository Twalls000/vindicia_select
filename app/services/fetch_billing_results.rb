class FetchBillingResults

  TRANSACTION_STATUS_TYPE = ["BillingNotAttempted", "Cancelled", "Captured", "Failed", "Refunded"]
  attr_accessor :start_timestamp, :end_timestamp, :page, :page_size

  # A Valid object must have the start time, and page size
  # The page may default to 0, if not provided.
  def initialize(args = {})
    @start_timestamp = args.fetch(:start_timestamp)
    @end_timestamp = args[:end_timestamp]
    @page_size = args.fetch(:page_size)
  end

  #
  # This section of code is to create the batches for the background
  # processor to later track every failed credit card in the centralized
  # table.
  #
  def self.process
    # Get the transactions and mark them for processing
    rns = ReturnNotificationSetting.first

    start_time = (Date.today - rns.checking_number_of_days.days).
                   in_time_zone("Pacific Time (US & Canada)").end_of_day + 1.second
    end_time   = (Date.today - rns.range_to_check.days).
                   in_time_zone("Pacific Time (US & Canada)").end_of_day

    # Have to pass the times as strings because DelayedJob won't accept time
    # objects as arguments.
    FetchBillingResultsJob.perform_later(start_time.to_s, end_time.to_s, rns.id)
  end

  #
  # This section will take a defined batch of credit cards and add to the
  # centralized table.
  #
  def fetch_billing_results
    previous_response = nil
    begin
      page = get_page_number

      response = Select.fetch_billing_results(@start_timestamp, @end_timestamp,
        page, @page_size)
      unless !response.is_a?(Array)
        process_response(response)
        previous_response = response
      end
    end until !response.is_a?(Array)
    reset_page_number

    set_empty_last_fetch_soap_id(response, previous_response)
  end

  def process_response response
    if response.is_a?(Array) && response.map(&:class).include?(Vindicia::Transaction)
      vindicia_transactions = response.select { |r| r.is_a? Vindicia::Transaction }
      mtids = vindicia_transactions.map(&:merchant_transaction_id)
      declined_trans = DeclinedCreditCardTransaction.find_by_merchant_transaction_id(mtids)
      soap_id = vindicia_transactions.first.soap_id
      declined_trans.each do |declined_tran|
        transaction = response.select { |r| r.merchant_transaction_id == declined_tran.merchant_transaction_id }.first
        if transaction && declined_tran.pending?
          declined_tran.name_values = transaction.name_values
          declined_tran.charge_status = transaction.status
          declined_tran.select_transaction_id = transaction.select_transaction_id
          declined_tran.auth_code = transaction.auth_code
          declined_tran.fetch_soap_id = soap_id
          declined_tran.success_audit_trails.build(event: "FetchBillingResults successful", soap_id: soap_id)
          declined_tran.status_update

          declined_tran.failed_to_send_to_genesys unless DeclinedCreditCard.send_transaction(declined_tran)
          declined_tran.save
        end
      end
    end
  end

  def set_empty_last_fetch_soap_id(last_response, previous_response)
    if last_response && previous_response
      soap_id = last_response[:soap_id] || "No soap_id"
      last_mtid = previous_response.last.merchant_transaction_id
      last_declined_card = DeclinedCreditCardTransaction.find_by_merchant_transaction_id(last_mtid).first

      # Attempt to find a Transaction in the DB from the last response to attach the soap ID to
      unless last_declined_card
        previous_response.map(&:merchant_transaction_id).each do |mtid|
          found_tran = DeclinedCreditCardTransaction.find_by_merchant_transaction_id(mtid).first
          if found_tran
            last_declined_card = found_tran
            break
          end
        end
      end

      if last_declined_card
        last_declined_card.empty_last_fetch_soap_id = soap_id
        last_declined_card.save
      else
        AuditTrail.create(event: "Problem assigning last soap ID #{soap_id}: DeclinedCreditCardTransaction with merchant_transaction_id \"#{last_mtid}\" does not exist in database")
      end
    end
  end

  def get_page_number
    rns = ReturnNotificationSetting.first
    page = rns.fetch_page_number
    rns.fetch_page_number += 1
    begin
      rns.save
      page
    rescue ActiveRecord::StaleObjectError
      get_page_number
    end
  end

  def reset_page_number
    rns = ReturnNotificationSetting.first
    rns.fetch_page_number = 0
    begin
      rns.save
    rescue ActiveRecord::StaleObjectError
      reset_page_number
    end
  end
end
