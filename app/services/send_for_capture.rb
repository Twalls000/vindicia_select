class SendForCapture
  #
  # This section of code is to send transactions to Vindicia Select
  #
  def self.process
    sample_trans = DeclinedCreditCardTransaction.oldest_unsent.limit(1)
    mp = sample_trans.market_publication
    pub_code = sample_trans.pub_code
    gci_unit = sample_trans.gci_unit

    transactions_to_send =
      DeclinedCreditCardTransaction.oldest_unsent.
        by_gci_unit_pub_code(gci_unit, pub_code).
        limit(sample_trans.market_publication.vindicia_batch_size)

    SendForCaptureJob.perform_later transactions
  end

  def self.send_transactions_for_capture(transactions)
    transactions.each do |trans|
      success = send_transaction(trans)

      # Updates the transaction's status
      success ? trans.send_to_vindicia! : trans.mark_in_error!
    end
  end

  def self.send_transaction(transaction)
    # Send to vindicia
  end

    #
    # This section will
    #

end
