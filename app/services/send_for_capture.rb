class SendForCapture
  #
  # This section of code is to send transactions to Vindicia Select
  #
  def self.process
    begin
      mp = get_next_batch
      if mp
        # Get the transactions and mark them for processing
        transactions_to_send = DeclinedCreditCardTransaction.oldest_unsent.
            by_gci_unit(mp.gci_unit).by_pub_code(mp.pub_code).
            limit(mp.vindicia_batch_size)
        transactions_to_send.each { |t| t.queue_to_vindicia! }

        SendForCaptureJob.perform_later transactions_to_send.map { |t| t.id }
      end
      mp = get_next_batch
    end until mp.nil?
  end

  def self.get_next_batch
    DeclinedCreditCardTransaction.oldest_unsent.first.try(:market_publication)
  end

  def self.send_transactions_for_capture(transactions_array)
    begin
      transactions = DeclinedCreditCardTransaction.get_queued_to_send_transactions(transactions_array)
      response = Select.bill_transactions transactions

      if response.is_a?(Array) && response.map(&:class).include?(Vindicia::TransactionValidationResponse)
        response.select { |r| r.is_a? Vindicia::TransactionValidationResponse }.each do |vtvr|
          trans = transactions.select { |t| t.merchant_transaction_id == vtvr.merchant_transaction_id }.first
          trans.audit_trails.build(event: "Vindicia code #{vtvr.code}: #{vtvr.description}")
          trans.soap_id = vtvr.soap_id
          vtvr.code.to_s == "200" ? trans.send_to_vindicia : trans.error_sending_to_vindicia
          trans.save
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
