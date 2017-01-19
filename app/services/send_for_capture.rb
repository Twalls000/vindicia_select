class SendForCapture
  #
  # This section of code is to send transactions to Vindicia Select
  #
  def self.process
    begin
      mp = get_next_batch
      submit_send_for_capture_job(mp)  if mp
      mp = get_next_batch
    end until mp.nil?
  end

  def self.get_next_batch
    DeclinedCreditCardTransaction.oldest_unsent.first.try(:market_publication)
  end

  def self.submit_send_for_capture_job(mp)
    # Get the transactions and mark them for processing
    transactions_to_send = DeclinedCreditCardTransaction.oldest_unsent.
        by_gci_unit(mp.gci_unit).by_pub_code(mp.pub_code).
        limit(mp.vindicia_batch_size)
    transactions_to_send.each { |t| t.queue_to_vindicia! }

    SendForCaptureJob.perform_later transactions_to_send.map { |t| t.id }
  end

  def self.send_transactions_for_capture(transactions_array)
    begin
      transactions = DeclinedCreditCardTransaction.get_queued_to_send_transactions(transactions_array)
      transactions.each(&:sending_to_vindicia!)
      response = Select.bill_transactions transactions

      if response.is_a?(Array) && response.map(&:class).include?(Vindicia::TransactionValidationResponse) || response.is_a?(Vindicia::TransactionValidationResponse)
        response = [response] if response.is_a?(Vindicia::TransactionValidationResponse)
        transactions.each do |t|
          vtvr = response.select { |r| r.is_a?(Vindicia::TransactionValidationResponse) &&
              r.merchant_transaction_id == t.merchant_transaction_id }.first
          if vtvr
            t.audit_trails.build(event: "Vindicia code #{vtvr.code}: #{vtvr.description}")
            t.soap_id = vtvr.soap_id
            t.error_sending_to_vindicia
            t.save
          else
            t.send_to_vindicia!
          end
        end
      elsif response.is_a?(Hash) && response[:soap_id]
        transactions.each do |t|
          t.soap_id = response[:soap_id]
          t.send_to_vindicia
          t.save
        end
      else
        transactions.each do |t|
          t.audit_trails.build(event: "Failed to send", exception: response)
          t.error_sending_to_vindicia
          t.save
        end
      end
    rescue => e
      transactions.each do |trans|
        trans.audit_trails.build(event: e.message, exception: e)
        trans.error_sending_to_vindicia
        trans.save
      end
    end
  end
end
