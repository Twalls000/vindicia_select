class SendForCapture
  #
  # This section of code is to send transactions to Vindicia Select
  #
  def self.process
    sample_trans = DeclinedCreditCardTransaction.oldest_unsent.limit(1).first
    mp = sample_trans.market_publication
    pub_code = mp.pub_code
    gci_unit = mp.gci_unit

    transactions_to_send =
      DeclinedCreditCardTransaction.oldest_unsent.
        by_gci_unit_and_pub_code(gci_unit, pub_code).
        limit(mp.market_publication.vindicia_batch_size)

    SendForCaptureJob.perform_later transactions_to_send.to_a
  end

  def self.send_transactions_for_capture(transactions)
    send_transactions transactions
  end

  def self.send_transactions(transactions)
    begin
      response = Select.bill_transactions transactions

      if response.is_a?(Array) && response.map(&:class).include?(Vindicia::TransactionValidationResponse)
        response.select { |r| r.is_a? Vindicia::TransactionValidationResponse }.each do |vtvr|
          trans = transactions.select { |t| t.merchant_transaction_id == vtvr.merchant_transaction_id }.first
          trans.audit_trails.build(event: "Vindicia code #{vtvr.code}: #{vtvr.description}")
          trans.mark_in_error
          trans.save
        end
      end
      transactions.select { |t| !t.in_error? }.each { |t| t.sent_to_vindicia! }

      response == true ? true : false
    rescue => e
      transactions.each do |trans|
        trans.audit_trails.build(event: e.message, exception: e)
        trans.mark_in_error
      end
      transactions.map(&:save)

      # maybe send an email?
      false
    end
  end
end
