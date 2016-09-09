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
        by_gci_unit_pub_code(gci_unit, pub_code).
        limit(mp.market_publication.vindicia_batch_size)

    SendForCaptureJob.perform_later transactions_to_send.to_a
  end

  def self.send_transactions_for_capture(transactions)
    transactions.each do |trans|
      success = send_transaction(trans)

      # Updates the transaction's status
      if success
        trans.sent_to_vindicia!
      else
        trans.mark_in_error!
        # TODO: Create an AuditTrail with the error that was sent back
      end
    end
  end

  def self.send_transaction(transaction)
    # Send to vindicia
  end

    #
    # This section will
    #

end
